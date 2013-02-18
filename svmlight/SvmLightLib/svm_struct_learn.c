/***********************************************************************/
/*                                                                     */
/*   svm_struct_learn.c                                                */
/*                                                                     */
/*   Basic algorithm for learning structured outputs (e.g. parses,     */
/*   sequences, multi-label classification) with a Support Vector      */ 
/*   Machine.                                                          */
/*                                                                     */
/*   Author: Thorsten Joachims                                         */
/*   Date: 26.06.06                                                    */
/*                                                                     */
/*   Copyright (c) 2006  Thorsten Joachims - All rights reserved       */
/*                                                                     */
/*   This software is available for non-commercial use only. It must   */
/*   not be modified and distributed without prior permission of the   */
/*   author. The author is not responsible for implications from the   */
/*   use of this software.                                             */
/*                                                                     */
/***********************************************************************/

#include "svm_struct_learn.h"
#include "svm_struct_common.h"
#include "svm_struct_api.h"
#include <assert.h>

#define MAX(x,y)      ((x) < (y) ? (y) : (x))
#define MIN(x,y)      ((x) > (y) ? (y) : (x))

void svm_learn_struct(SAMPLE sample, STRUCT_LEARN_PARM *sparm,
		      LEARN_PARM *lparm, KERNEL_PARM *kparm, 
		      STRUCTMODEL *sm, HIDEO_ENV *hideo_env)
{
  int         i,j;
  int         numIt=0;
  long        argmax_count=0;
  long        newconstraints=0, totconstraints=0, activenum=0; 
  int         opti_round, *opti, fullround;
  long        old_numConst=0;
  double      epsilon,svmCnorm;
  long        tolerance,new_precision=1;
  double      lossval,factor,dist;
  double      margin=0;
  double      slack, *slacks, slacksum, ceps;
  double      dualitygap,modellength,alphasum;
  long        sizePsi;
  double      *alpha=NULL;
  long        *alphahist=NULL,optcount=0,lastoptcount=0;
  CONSTSET    cset;
  SVECTOR     *diff=NULL;
  SVECTOR     *fy, *fybar, *f, **fycache=NULL;
  SVECTOR     *slackvec;
  WORD        slackv[2];
  MODEL       *svmModel=NULL;
  KERNEL_CACHE *kcache=NULL;
  LABEL       ybar;
  DOC         *doc;

  long        n=sample.n;
  EXAMPLE     *ex=sample.examples;
  double      rt_total=0, rt_opt=0, rt_init=0, rt_psi=0, rt_viol=0;
  double      rt1,rt2;

  rt1=get_runtime();

  init_struct_model(sample,sm,sparm,lparm,kparm); 
  sizePsi=sm->sizePsi+1;          /* sm must contain size of psi on return */

  /* initialize example selection heuristic */ 
  opti=(int*)my_malloc(n*sizeof(int));
  for(i=0;i<n;i++) {
    opti[i]=0;
  }
  opti_round=0;

  /* normalize regularization parameter C by the number of training examples */
  svmCnorm=sparm->C/n;

  if(sparm->slack_norm == 1) {
    lparm->svm_c=svmCnorm;          /* set upper bound C */
    lparm->sharedslack=1;
  }
  else if(sparm->slack_norm == 2) {
    lparm->svm_c=999999999999999.0; /* upper bound C must never be reached */
    lparm->sharedslack=0;
    if(kparm->kernel_type != LINEAR) {
      printf("ERROR: Kernels are not implemented for L2 slack norm!"); 
      fflush(stdout);
      exit(0); 
    }
  }
  else {
    printf("ERROR: Slack norm must be L1 or L2!"); fflush(stdout);
    exit(0);
  }


  epsilon=100.0;                  /* start with low precision and
				     increase later */
  tolerance=MIN(n/3,MAX(n/100,5));/* increase precision, whenever less
                                     than that number of constraints
                                     is not fulfilled */
  lparm->biased_hyperplane=0;     /* set threshold to zero */

  cset=init_struct_constraints(sample, sm, sparm);
  if(cset.m > 0) {
    alpha=(double *)realloc(alpha,sizeof(double)*cset.m);
    alphahist=(long *)realloc(alphahist,sizeof(long)*cset.m);
    for(i=0; i<cset.m; i++) {
      alpha[i]=0;
      alphahist[i]=-1; /* -1 makes sure these constraints are never removed */
    }
  }

  /* set initial model and slack variables*/
  svmModel=(MODEL *)my_malloc(sizeof(MODEL));
  svmModel->n_td_pred=0;
  svmModel->td_pred=NULL;
  lparm->epsilon_crit=epsilon;
  if(kparm->kernel_type != LINEAR)
    kcache=kernel_cache_init(MAX(cset.m,1),lparm->kernel_cache_size);
  svm_learn_optimization(cset.lhs,cset.rhs,cset.m,sizePsi+n,
			 lparm,kparm,kcache,svmModel,alpha,hideo_env);
  if(kcache)
    kernel_cache_cleanup(kcache);
  add_weight_vector_to_linear_model(svmModel);
  sm->svm_model=svmModel;
  sm->w=svmModel->lin_weights; /* short cut to weight vector */

  /* create a cache of the feature vectors for the correct labels */
  if(USE_FYCACHE) {
    fycache=(SVECTOR **)malloc(n*sizeof(SVECTOR *));
    for(i=0;i<n;i++) {
      fy=psi(ex[i].x,ex[i].y,sm,sparm);
      if(kparm->kernel_type == LINEAR) {
	diff=add_list_ss(fy); /* store difference vector directly */
	free_svector(fy);
	fy=diff;
      }
      fycache[i]=fy;
    }
  }

  rt_init+=MAX(get_runtime()-rt1,0);
  rt_total+=MAX(get_runtime()-rt1,0);

    /*****************/
   /*** main loop ***/
  /*****************/
  do { /* iteratively increase precision */

    epsilon=MAX(epsilon*0.49999999999,sparm->epsilon);
    new_precision=1;
    if(epsilon == sparm->epsilon)   /* for final precision, find all SV */
      tolerance=0; 
    lparm->epsilon_crit=epsilon/2;  /* svm precision must be higher than eps */
    if(struct_verbosity>=1)
      printf("Setting current working precision to %g.\n",epsilon);

    do { /* iteration until (approx) all SV are found for current
            precision and tolerance */
      
      opti_round++;
      activenum=n;

      do { /* go through examples that keep producing new constraints */

	if(struct_verbosity>=1) { 
	  printf("Iter %i (%ld active): ",++numIt,activenum); 
	  fflush(stdout);
	}
	
	old_numConst=cset.m;
	ceps=0;
	fullround=(activenum == n);

	for(i=0; i<n; i++) { /*** example loop ***/
	  
	  rt1=get_runtime();
	    
	  if(opti[i] != opti_round) {/* if the example is not shrunk
	                                away, then see if it is necessary to 
					add a new constraint */
	    rt2=get_runtime();
	    argmax_count++;
	    if(sparm->loss_type == SLACK_RESCALING) 
	      ybar=find_most_violated_constraint_slackrescaling(ex[i].x,
								ex[i].y,sm,
								sparm);
	    else
	      ybar=find_most_violated_constraint_marginrescaling(ex[i].x,
								 ex[i].y,sm,
								 sparm);
	    rt_viol+=MAX(get_runtime()-rt2,0);
	    
	    if(empty_label(ybar)) {
	      if(opti[i] != opti_round) {
		activenum--;
		opti[i]=opti_round; 
	      }
	      if(struct_verbosity>=2)
		printf("no-incorrect-found(%i) ",i);
	      continue;
	    }
	  
	    /**** get psi(y)-psi(ybar) ****/
	    rt2=get_runtime();
	    if(fycache) 
	      fy=copy_svector(fycache[i]);
	    else
	      fy=psi(ex[i].x,ex[i].y,sm,sparm);
	    fybar=psi(ex[i].x,ybar,sm,sparm);
	    rt_psi+=MAX(get_runtime()-rt2,0);
	    
	    /**** scale feature vector and margin by loss ****/
	    lossval=loss(ex[i].y,ybar,sparm);
	    if(sparm->slack_norm == 2)
	      lossval=sqrt(lossval);
	    if(sparm->loss_type == SLACK_RESCALING)
	      factor=lossval;
	    else               /* do not rescale vector for */
	      factor=1.0;      /* margin rescaling loss type */
	    for(f=fy;f;f=f->next)
	      f->factor*=factor;
	    for(f=fybar;f;f=f->next)
	      f->factor*=-factor;
	    margin=lossval;

	    /**** create constraint for current ybar ****/
	    append_svector_list(fy,fybar);/* append the two vector lists */
	    doc=create_example(cset.m,0,i+1,1,fy);

	    /**** compute slack for this example ****/
	    slack=0;
	    for(j=0;j<cset.m;j++) 
	      if(cset.lhs[j]->slackid == i+1) {
		if(sparm->slack_norm == 2) /* works only for linear kernel */
		  slack=MAX(slack,cset.rhs[j]
			          -(classify_example(svmModel,cset.lhs[j])
				    -sm->w[sizePsi+i]/(sqrt(2*svmCnorm))));
		else
		  slack=MAX(slack,
			   cset.rhs[j]-classify_example(svmModel,cset.lhs[j]));
	      }
	    
	    /**** if `error' add constraint and recompute ****/
	    dist=classify_example(svmModel,doc);
	    ceps=MAX(ceps,margin-dist-slack);
	    if(slack > (margin-dist+0.0001)) {
	      printf("\nWARNING: Slack of most violated constraint is smaller than slack of working\n");
	      printf("         set! There is probably a bug in 'find_most_violated_constraint_*'.\n");
	      printf("Ex %d: slack=%f, newslack=%f\n",i,slack,margin-dist);
	      /* exit(1); */
	    }
	    if((dist+slack)<(margin-epsilon)) { 
	      if(struct_verbosity>=2)
		{printf("(%i,eps=%.2f) ",i,margin-dist-slack); fflush(stdout);}
	      if(struct_verbosity==1)
		{printf("."); fflush(stdout);}
	      
	      /**** resize constraint matrix and add new constraint ****/
	      cset.m++;
	      cset.lhs=(DOC **)realloc(cset.lhs,sizeof(DOC *)*cset.m);
	      if(kparm->kernel_type == LINEAR) {
		diff=add_list_ss(fy); /* store difference vector directly */
		if(sparm->slack_norm == 1) 
		  cset.lhs[cset.m-1]=create_example(cset.m-1,0,i+1,1,
						    copy_svector(diff));
		else if(sparm->slack_norm == 2) {
		  /**** add squared slack variable to feature vector ****/
		  slackv[0].wnum=sizePsi+i;
		  slackv[0].weight=1/(sqrt(2*svmCnorm));
		  slackv[1].wnum=0; /*terminator*/
		  slackvec=create_svector(slackv,"",1.0);
		  cset.lhs[cset.m-1]=create_example(cset.m-1,0,i+1,1,
						    add_ss(diff,slackvec));
		  free_svector(slackvec);
		}
		free_svector(diff);
	      }
	      else { /* kernel is used */
		if(sparm->slack_norm == 1) 
		  cset.lhs[cset.m-1]=create_example(cset.m-1,0,i+1,1,
						    copy_svector(fy));
		else if(sparm->slack_norm == 2)
		  exit(1);
	      }
	      cset.rhs=(double *)realloc(cset.rhs,sizeof(double)*cset.m);
	      cset.rhs[cset.m-1]=margin;
	      alpha=(double *)realloc(alpha,sizeof(double)*cset.m);
	      alpha[cset.m-1]=0;
	      alphahist=(long *)realloc(alphahist,sizeof(long)*cset.m);
	      alphahist[cset.m-1]=optcount;
	      newconstraints++;
	      totconstraints++;
	    }
	    else {
	      printf("+"); fflush(stdout); 
	      if(opti[i] != opti_round) {
		activenum--;
		opti[i]=opti_round; 
	      }
	    }

	    free_example(doc,0);
	    free_svector(fy); /* this also free's fybar */
	    free_label(ybar);
	  }

	  /**** get new QP solution ****/
	  if((newconstraints >= sparm->newconstretrain) 
	     || ((newconstraints > 0) && (i == n-1))
	     || (new_precision && (i == n-1))) {
	    if(struct_verbosity>=1) {
	      printf("*");fflush(stdout);
	    }
	    rt2=get_runtime();
	    free_model(svmModel,0);
	    svmModel=(MODEL *)my_malloc(sizeof(MODEL));
		svmModel->n_td_pred=0;
		svmModel->td_pred=NULL;
	    /* Always get a new kernel cache. It is not possible to use the
	       same cache for two different training runs */
	    if(kparm->kernel_type != LINEAR)
	      kcache=kernel_cache_init(MAX(cset.m,1),lparm->kernel_cache_size);
	    /* Run the QP solver on cset. */
	    svm_learn_optimization(cset.lhs,cset.rhs,cset.m,sizePsi+n,
				   lparm,kparm,kcache,svmModel,alpha,hideo_env);
	    if(kcache)
	      kernel_cache_cleanup(kcache);
	    /* Always add weight vector, in case part of the kernel is
	       linear. If not, ignore the weight vector since its
	       content is bogus. */
	    add_weight_vector_to_linear_model(svmModel);
	    sm->svm_model=svmModel;
	    sm->w=svmModel->lin_weights; /* short cut to weight vector */
	    optcount++;
	    /* keep track of when each constraint was last
	       active. constraints marked with -1 are not updated */
	    for(j=0;j<cset.m;j++) 
	      if((alphahist[j]>-1) && (alpha[j] != 0))  
		alphahist[j]=optcount;
	    rt_opt+=MAX(get_runtime()-rt2,0);
	    
	    new_precision=0;
	    newconstraints=0;
	  }	

	  rt_total+=MAX(get_runtime()-rt1,0);

	} /* end of example loop */

	rt1=get_runtime();
	
	if(struct_verbosity>=1)
	  printf("(NumConst=%d, SV=%ld, CEps=%.4f, QPEps=%.4f)\n",cset.m,
		 svmModel->sv_num-1,ceps,svmModel->maxdiff);
	
	/* Check if some of the linear constraints have not been
	   active in a while. Those constraints are then removed to
	   avoid bloating the working set beyond necessity. */
	if(struct_verbosity>=2)
	  printf("Reducing working set...");fflush(stdout);
	remove_inactive_constraints(&cset,alpha,optcount,alphahist,
				    MAX(50,optcount-lastoptcount));
	lastoptcount=optcount;
	if(struct_verbosity>=2)
	  printf("done. (NumConst=%d)\n",cset.m);
	
	rt_total+=MAX(get_runtime()-rt1,0);
	
      } while(activenum > 0);   /* repeat until all examples produced no
				   constraint at least once */

    } while(((cset.m - old_numConst) > tolerance) || (!fullround));

  } while((epsilon > sparm->epsilon) 
	  || finalize_iteration(ceps,0,sample,sm,cset,alpha,sparm));  

  if(struct_verbosity>=1) {
    /**** compute sum of slacks ****/
    /**** WARNING: If positivity constraints are used, then the
	  maximum slack id is larger than what is allocated
	  below ****/
    slacks=(double *)my_malloc(sizeof(double)*(n+1));
    for(i=0; i<=n; i++) { 
      slacks[i]=0;
    }
    if(sparm->slack_norm == 1) {
      for(j=0;j<cset.m;j++) 
	slacks[cset.lhs[j]->slackid]=MAX(slacks[cset.lhs[j]->slackid],
			   cset.rhs[j]-classify_example(svmModel,cset.lhs[j]));
      }
    else if(sparm->slack_norm == 2) {
      for(j=0;j<cset.m;j++) 
	slacks[cset.lhs[j]->slackid]=MAX(slacks[cset.lhs[j]->slackid],
		cset.rhs[j]
	         -(classify_example(svmModel,cset.lhs[j])
		   -sm->w[sizePsi+cset.lhs[j]->slackid-1]/(sqrt(2*svmCnorm))));
    }
    slacksum=0;
    for(i=1; i<=n; i++)  
      slacksum+=slacks[i];
    free(slacks);
    alphasum=0;
    for(i=0; i<cset.m; i++)  
      alphasum+=alpha[i]*cset.rhs[i];
    modellength=model_length_s(svmModel,kparm);
    dualitygap=(0.5*modellength*modellength+svmCnorm*(slacksum+n*ceps))
               -(alphasum-0.5*modellength*modellength);
    
    printf("Final epsilon on KKT-Conditions: %.5f\n",
	   MAX(svmModel->maxdiff,epsilon));
    printf("Upper bound on duality gap: %.5f\n", dualitygap);
    printf("Dual objective value: dval=%.5f\n",
	    alphasum-0.5*modellength*modellength);
    printf("Total number of constraints in final working set: %i (of %i)\n",(int)cset.m,(int)totconstraints);
    printf("Number of iterations: %d\n",numIt);
    printf("Number of calls to 'find_most_violated_constraint': %ld\n",argmax_count);
    if(sparm->slack_norm == 1) {
      printf("Number of SV: %ld \n",svmModel->sv_num-1);
      printf("Number of non-zero slack variables: %ld (out of %ld)\n",
	     svmModel->at_upper_bound,n);
      printf("Norm of weight vector: |w|=%.5f\n",
	     model_length_s(svmModel,kparm));
    }
    else if(sparm->slack_norm == 2){ 
      printf("Number of SV: %ld (including %ld at upper bound)\n",
	     svmModel->sv_num-1,svmModel->at_upper_bound);
      printf("Norm of weight vector (including L2-loss): |w|=%.5f\n",
	     model_length_s(svmModel,kparm));
    }
    printf("Norm. sum of slack variables (on working set): sum(xi_i)/n=%.5f\n",slacksum/n);
    printf("Norm of longest difference vector: ||Psi(x,y)-Psi(x,ybar)||=%.5f\n",
	   length_of_longest_document_vector(cset.lhs,cset.m,kparm));
    printf("Runtime in cpu-seconds: %.2f (%.2f%% for QP, %.2f%% for Argmax, %.2f%% for Psi, %.2f%% for init)\n",
	   rt_total/100.0, (100.0*rt_opt)/rt_total, (100.0*rt_viol)/rt_total, 
	   (100.0*rt_psi)/rt_total, (100.0*rt_init)/rt_total);
  }
  if(struct_verbosity>=4)
    printW(sm->w,sizePsi,n,lparm->svm_c);

  if(svmModel) {
    sm->svm_model=copy_model(svmModel);
    sm->w=sm->svm_model->lin_weights; /* short cut to weight vector */
  }

  print_struct_learning_stats(sample,sm,cset,alpha,sparm);

  if(fycache) {
    for(i=0;i<n;i++)
      free_svector(fycache[i]);
    free(fycache);
  }
  if(svmModel)
    free_model(svmModel,0);
  free(alpha); 
  free(alphahist); 
  free(opti); 
  free(cset.rhs); 
  for(i=0;i<cset.m;i++) 
    free_example(cset.lhs[i],1);
  free(cset.lhs);
  free_env(hideo_env);
}

void svm_learn_struct_joint(SAMPLE sample, STRUCT_LEARN_PARM *sparm,
			    LEARN_PARM *lparm, KERNEL_PARM *kparm, 
			    STRUCTMODEL *sm, int alg_type, HIDEO_ENV *hideo_env)
{
  int         i,j;
  int         numIt=0;
  long        argmax_count=0;
  long        totconstraints=0;
  long        kernel_type_org;
  double      epsilon,epsilon_cached;
  double      lossval,factor,dist;
  double      margin=0;
  double      slack, slacksum, ceps;
  double      dualitygap,modellength,alphasum;
  long        sizePsi;
  double      *alpha=NULL;
  long        *alphahist=NULL,optcount=0;
  CONSTSET    cset;
  SVECTOR     *diff=NULL;
  double      *diff_n=NULL;
  SVECTOR     *fy, *fybar, *f, **fycache, *lhs;
  MODEL       *svmModel=NULL;
  LABEL       ybar;
  DOC         *doc;

  long        n=sample.n;
  EXAMPLE     *ex=sample.examples;
  double      rt_total=0,rt_opt=0,rt_init=0,rt_psi=0,rt_viol=0,rt_kernel=0;
  double      rt1,rt2;
  double      progress,progress_old;

  /*
  SVECTOR     ***fydelta_cache=NULL;
  double      **loss_cache=NULL;
  int         cache_size=0;
  */
  CCACHE      *ccache=NULL;
  int         cached_constraint;

  rt1=get_runtime();

  init_struct_model(sample,sm,sparm,lparm,kparm); 
  sizePsi=sm->sizePsi+1;          /* sm must contain size of psi on return */

  if(sparm->slack_norm == 1) {
    lparm->svm_c=sparm->C;          /* set upper bound C */
    lparm->sharedslack=1;
  }
  else if(sparm->slack_norm == 2) {
    printf("ERROR: The joint algorithm does not apply to L2 slack norm!"); 
    fflush(stdout);
    exit(0); 
  }
  else {
    printf("ERROR: Slack norm must be L1 or L2!"); fflush(stdout);
    exit(0);
  }


  lparm->biased_hyperplane=0;     /* set threshold to zero */
  epsilon=100.0;                  /* start with low precision and
				     increase later */
  epsilon_cached=epsilon;         /* epsilon to use for iterations
				     using constraints constructed
				     from the constraint cache */

  cset=init_struct_constraints(sample, sm, sparm);
  if(cset.m > 0) {
    alpha=(double *)realloc(alpha,sizeof(double)*cset.m);
    alphahist=(long *)realloc(alphahist,sizeof(long)*cset.m);
    for(i=0; i<cset.m; i++) {
      alpha[i]=0;
      alphahist[i]=-1; /* -1 makes sure these constraints are never removed */
    }
  }
  kparm->gram_matrix=NULL;
  if((alg_type == DUAL_ALG) || (alg_type == DUAL_CACHE_ALG))
    kparm->gram_matrix=init_kernel_matrix(&cset,kparm);

  /* set initial model and slack variables */
  svmModel=(MODEL *)my_malloc(sizeof(MODEL));
  svmModel->n_td_pred=0;
  svmModel->td_pred=NULL;
  lparm->epsilon_crit=epsilon;
  svm_learn_optimization(cset.lhs,cset.rhs,cset.m,sizePsi+n,
			 lparm,kparm,NULL,svmModel,alpha,hideo_env);
  add_weight_vector_to_linear_model(svmModel);
  sm->svm_model=svmModel;
  sm->w=svmModel->lin_weights; /* short cut to weight vector */

  /* create a cache of the feature vectors for the correct labels */
  fycache=(SVECTOR **)malloc(n*sizeof(SVECTOR *));
  for(i=0;i<n;i++) {
    fy=psi(ex[i].x,ex[i].y,sm,sparm);
    if(kparm->kernel_type == LINEAR) {
      diff=add_list_ss(fy); /* store difference vector directly */
      free_svector(fy);
      fy=diff;
    }
    fycache[i]=fy;
  }

  /* initialize the constraint cache */
  if(alg_type == DUAL_CACHE_ALG) {
    ccache=create_constraint_cache(sample,sparm);
  }

  rt_init+=MAX(get_runtime()-rt1,0);
  rt_total+=MAX(get_runtime()-rt1,0);

    /*****************/
   /*** main loop ***/
  /*****************/
  do { /* iteratively find and add constraints to working set */

      if(struct_verbosity>=1) { 
	printf("Iter %i: ",++numIt); 
	fflush(stdout);
      }
      
      rt1=get_runtime();

      /**** compute current slack ****/
      slack=0;
      for(j=0;j<cset.m;j++) 
	slack=MAX(slack,cset.rhs[j]-classify_example(svmModel,cset.lhs[j]));
      
      /**** find a violated joint constraint ****/
      lhs=NULL;
      dist=0;
      if(alg_type == DUAL_CACHE_ALG) {
	/* see if it is possible to construct violated constraint from cache */
	update_constraint_cache_for_model(ccache, svmModel);
	dist=find_most_violated_joint_constraint_in_cache(ccache,&lhs,&margin);
      }

      rt_total+=MAX(get_runtime()-rt1,0);

      /* Is there a sufficiently violated constraint in cache? */
      if(dist-slack > MAX(epsilon/10,sparm->epsilon)) { 
	/* use constraint from cache */
	rt1=get_runtime();
	cached_constraint=1;
	if(kparm->kernel_type == LINEAR) {
	  diff=add_list_ns(lhs); /* Linear case: compute weighted sum */
	  free_svector_shallow(lhs);
	}
	else { /* Non-linear case: make sure we have deep copy for cset */
	  diff=copy_svector(lhs); 
	  free_svector_shallow(lhs);
	}
	rt_total+=MAX(get_runtime()-rt1,0);
      }
      else { 
	/* do not use constraint from cache */
	rt1=get_runtime();
	cached_constraint=0;
	if(lhs)
	  free_svector_shallow(lhs);
	lhs=NULL;
	if(kparm->kernel_type == LINEAR) {
	  diff_n=create_nvector(sm->sizePsi);
	  clear_nvector(diff_n,sm->sizePsi);
	}
	margin=0;
	progress=0;
	progress_old=progress;
	rt_total+=MAX(get_runtime()-rt1,0);

	/**** find most violated joint constraint ***/
	for(i=0; i<n; i++) {
	  
	  rt1=get_runtime();
      
	  progress+=10.0/n;
	  if((struct_verbosity==1) && (((int)progress_old) != ((int)progress)))
	    {printf(".");fflush(stdout); progress_old=progress;}
	  if(struct_verbosity>=2)
	    {printf("."); fflush(stdout);}

	  rt2=get_runtime();
	  argmax_count++;
	  if(sparm->loss_type == SLACK_RESCALING) 
	    ybar=find_most_violated_constraint_slackrescaling(ex[i].x,
							      ex[i].y,sm,
							      sparm);
	  else
	    ybar=find_most_violated_constraint_marginrescaling(ex[i].x,
							       ex[i].y,sm,
							       sparm);
	  rt_viol+=MAX(get_runtime()-rt2,0);
	  
	  if(empty_label(ybar)) {
	    printf("ERROR: empty label was returned for example (%i)\n",i);
	    /* exit(1); */
	    continue;
	  }
	  
	  /**** get psi(x,y) and psi(x,ybar) ****/
	  rt2=get_runtime();
	  fy=copy_svector(fycache[i]); /*<= fy=psi(ex[i].x,ex[i].y,sm,sparm);*/
	  fybar=psi(ex[i].x,ybar,sm,sparm);
	  rt_psi+=MAX(get_runtime()-rt2,0);
	  lossval=loss(ex[i].y,ybar,sparm);
	  free_label(ybar);
	  
	  /**** scale feature vector and margin by loss ****/
	  if(sparm->loss_type == SLACK_RESCALING)
	    factor=lossval/n;
	  else                 /* do not rescale vector for */
	    factor=1.0/n;      /* margin rescaling loss type */
	  for(f=fy;f;f=f->next)
	    f->factor*=factor;
	  for(f=fybar;f;f=f->next)
	    f->factor*=-factor;
	  append_svector_list(fybar,fy);   /* compute fy-fybar */
	  
	  /**** add current fy-fybar and loss to cache ****/
	  if(alg_type == DUAL_CACHE_ALG) {
	    if(kparm->kernel_type == LINEAR) 
	      add_constraint_to_constraint_cache(ccache,svmModel,i,
						 add_list_ss(fybar),
						 lossval/n,sparm->ccache_size);
	    else
	      add_constraint_to_constraint_cache(ccache,svmModel,i,
						 copy_svector(fybar),
						 lossval/n,sparm->ccache_size);
	  }

	  /**** add current fy-fybar to constraint and margin ****/
	  if(kparm->kernel_type == LINEAR) {
	    add_list_n_ns(diff_n,fybar,1.0); /* add fy-fybar to sum */
	    free_svector(fybar);
	  }
	  else {
	    append_svector_list(fybar,lhs);  /* add fy-fybar to vector list */
	    lhs=fybar;
	  }
	  margin+=lossval/n;                 /* add loss to rhs */
	  
	  rt_total+=MAX(get_runtime()-rt1,0);

	} /* end of example loop */

	rt1=get_runtime();

	/* create sparse vector from dense sum */
	if(kparm->kernel_type == LINEAR) {
	  diff=create_svector_n(diff_n,sm->sizePsi,"",1.0);
	  free_nvector(diff_n);
	}
	else {
	  diff=lhs;
	}

	rt_total+=MAX(get_runtime()-rt1,0);

      } /* end of finding most violated joint constraint */

      rt1=get_runtime();

      /**** if `error', then add constraint and recompute QP ****/
      doc=create_example(cset.m,0,1,1,diff);
      dist=classify_example(svmModel,doc);
      ceps=MAX(0,margin-dist-slack);
      if(slack > (margin-dist+0.000001)) {
	printf("\nWARNING: Slack of most violated constraint is smaller than slack of working\n");
	printf("         set! There is probably a bug in 'find_most_violated_constraint_*'.\n");
	printf("slack=%f, newslack=%f\n",slack,margin-dist);
	/* exit(1); */
      }
      if(ceps > sparm->epsilon) { 
	/**** resize constraint matrix and add new constraint ****/
	cset.lhs=(DOC **)realloc(cset.lhs,sizeof(DOC *)*(cset.m+1));
	if(sparm->slack_norm == 1) 
	  cset.lhs[cset.m]=create_example(cset.m,0,1,1,diff);
	else if(sparm->slack_norm == 2)
	  exit(1);
	cset.rhs=(double *)realloc(cset.rhs,sizeof(double)*(cset.m+1));
	cset.rhs[cset.m]=margin;
	alpha=(double *)realloc(alpha,sizeof(double)*(cset.m+1));
	alpha[cset.m]=0;
	alphahist=(long *)realloc(alphahist,sizeof(long)*(cset.m+1));
	alphahist[cset.m]=optcount;
	cset.m++;
	totconstraints++;
	if((alg_type == DUAL_ALG) || (alg_type == DUAL_CACHE_ALG)) {
	  if(struct_verbosity>=1) {
	    printf(":");fflush(stdout);
	  }
	  rt2=get_runtime();
	  kparm->gram_matrix=update_kernel_matrix(kparm->gram_matrix,cset.m-1,
						  &cset,kparm);
	  rt_kernel+=MAX(get_runtime()-rt2,0);
	}
	
	/**** get new QP solution ****/
	if(struct_verbosity>=1) {
	  printf("*");fflush(stdout);
	}
	rt2=get_runtime();
	/* set svm precision so that higher than eps of most violated constr */
	if(cached_constraint) {
	  epsilon_cached=MIN(epsilon_cached,MAX(ceps,sparm->epsilon)); 
	  lparm->epsilon_crit=epsilon_cached/2; 
	}
	else {
	  epsilon=MIN(epsilon,MAX(ceps,sparm->epsilon)); /* best eps so far */
	  lparm->epsilon_crit=epsilon/2; 
	  epsilon_cached=epsilon;
	}
	free_model(svmModel,0);
	svmModel=(MODEL *)my_malloc(sizeof(MODEL));
	svmModel->n_td_pred=0;
	svmModel->td_pred=NULL;
	/* Run the QP solver on cset. */
	kernel_type_org=kparm->kernel_type;
	if((alg_type == DUAL_ALG) || (alg_type == DUAL_CACHE_ALG))
	  kparm->kernel_type=GRAM; /* use kernel stored in kparm */
	svm_learn_optimization(cset.lhs,cset.rhs,cset.m,sizePsi+n,
			       lparm,kparm,NULL,svmModel,alpha,hideo_env);
	kparm->kernel_type=kernel_type_org; 
	svmModel->kernel_parm.kernel_type=kernel_type_org;
	/* Always add weight vector, in case part of the kernel is
	   linear. If not, ignore the weight vector since its
	   content is bogus. */
	add_weight_vector_to_linear_model(svmModel);
	sm->svm_model=svmModel;
	sm->w=svmModel->lin_weights; /* short cut to weight vector */
	optcount++;
	/* keep track of when each constraint was last
	   active. constraints marked with -1 are not updated */
	for(j=0;j<cset.m;j++) 
	  if((alphahist[j]>-1) && (alpha[j] != 0))  
	    alphahist[j]=optcount;
	rt_opt+=MAX(get_runtime()-rt2,0);
	
	/* Check if some of the linear constraints have not been
	   active in a while. Those constraints are then removed to
	   avoid bloating the working set beyond necessity. */
	if(struct_verbosity>=2)
	  printf("Reducing working set...");fflush(stdout);
	remove_inactive_constraints(&cset,alpha,optcount,alphahist,50);
	if(struct_verbosity>=2)
	  printf("done. (NumConst=%d) ",cset.m);
      }
      else {
	free_svector(diff);
      }

      if(struct_verbosity>=1)
	printf("(NumConst=%d, SV=%ld, CEps=%.4f, QPEps=%.4f)\n",cset.m,
	       svmModel->sv_num-1,ceps,svmModel->maxdiff);

      free_example(doc,0);
	
      rt_total+=MAX(get_runtime()-rt1,0);

  } while((ceps > sparm->epsilon) || 
	  finalize_iteration(ceps,cached_constraint,sample,sm,cset,alpha,sparm)
	 );
  

  if(struct_verbosity>=1) {
    /**** compute sum of slacks ****/
    /**** WARNING: If positivity constraints are used, then the
	  maximum slack id is larger than what is allocated
	  below ****/
    slacksum=0;
    if(sparm->slack_norm == 1) {
      for(j=0;j<cset.m;j++) 
	slacksum=MAX(slacksum,
		     cset.rhs[j]-classify_example(svmModel,cset.lhs[j]));
      }
    else if(sparm->slack_norm == 2) {
      exit(1);
    }
    alphasum=0;
    for(i=0; i<cset.m; i++)  
      alphasum+=alpha[i]*cset.rhs[i];
    modellength=model_length_s(svmModel,kparm);
    dualitygap=(0.5*modellength*modellength+sparm->C*(slacksum+ceps))
               -(alphasum-0.5*modellength*modellength);
    
    printf("Final epsilon on KKT-Conditions: %.5f\n",
	   MAX(svmModel->maxdiff,ceps));
    printf("Upper bound on duality gap: %.5f\n", dualitygap);
    printf("Dual objective value: dval=%.5f\n",
	    alphasum-0.5*modellength*modellength);
    printf("Total number of constraints in final working set: %i (of %i)\n",(int)cset.m,(int)totconstraints);
    printf("Number of iterations: %d\n",numIt);
    printf("Number of calls to 'find_most_violated_constraint': %ld\n",argmax_count);
    if(sparm->slack_norm == 1) {
      printf("Number of SV: %ld \n",svmModel->sv_num-1);
      printf("Norm of weight vector: |w|=%.5f\n",
	     model_length_s(svmModel,kparm));
    }
    else if(sparm->slack_norm == 2){ 
      printf("Number of SV: %ld (including %ld at upper bound)\n",
	     svmModel->sv_num-1,svmModel->at_upper_bound);
      printf("Norm of weight vector (including L2-loss): |w|=%.5f\n",
	     model_length_s(svmModel,kparm));
    }
    printf("Value of slack variable (on working set): xi=%.5f\n",slacksum);
    printf("Norm of longest difference vector: ||Psi(x,y)-Psi(x,ybar)||=%.5f\n",
	   length_of_longest_document_vector(cset.lhs,cset.m,kparm));
    printf("Runtime in cpu-seconds: %.2f (%.2f%% for QP, %.2f%% for kernel, %.2f%% for Argmax, %.2f%% for Psi, %.2f%% for init)\n",
	   rt_total/100.0, (100.0*rt_opt)/rt_total, (100.0*rt_kernel)/rt_total,
	   (100.0*rt_viol)/rt_total, (100.0*rt_psi)/rt_total, 
	   (100.0*rt_init)/rt_total);
  }
  if(ccache) {
    long cnum=0;
    CCACHEELEM *celem;
    for(i=0;i<n;i++) 
      for(celem=ccache->constlist[i];celem;celem=celem->next) 
	cnum++;
    printf("Final number of constraints in cache: %ld\n",cnum);
  }
  if(struct_verbosity>=4)
    printW(sm->w,sizePsi,n,lparm->svm_c);

  if(svmModel) {
    sm->svm_model=copy_model(svmModel);
    sm->w=sm->svm_model->lin_weights; /* short cut to weight vector */
  }

  print_struct_learning_stats(sample,sm,cset,alpha,sparm);

  if(ccache)    
    free_constraint_cache(ccache);
  for(i=0;i<n;i++)
    free_svector(fycache[i]);
  free(fycache);
  if(svmModel)
    free_model(svmModel,0);
  free(alpha); 
  free(alphahist); 
  free(cset.rhs); 
  for(i=0;i<cset.m;i++) 
    free_example(cset.lhs[i],1);
  free(cset.lhs);
  if(kparm->gram_matrix)
    free_matrix(kparm->gram_matrix);
  free_env(hideo_env);
}



void remove_inactive_constraints(CONSTSET *cset, double *alpha, 
			         long currentiter, long *alphahist, 
				 long mininactive)
     /* removes the constraints from cset (and alpha) for which
	alphahist indicates that they have not been active for at
	least mininactive iterations */

{  
  long i,m;
  
  m=0;
  for(i=0;i<cset->m;i++) {
    if((alphahist[i]<0) || ((currentiter-alphahist[i]) < mininactive)) {
      /* keep constraints that are marked as -1 or which have recently
         been active */
      cset->lhs[m]=cset->lhs[i];      
      cset->lhs[m]->docnum=m;
      cset->rhs[m]=cset->rhs[i];
      alpha[m]=alpha[i];
      alphahist[m]=alphahist[i];
      m++;
    }
    else {
      free_example(cset->lhs[i],1);
    }
  }
  if(cset->m != m) {
    cset->m=m;
    cset->lhs=(DOC **)realloc(cset->lhs,sizeof(DOC *)*cset->m);
    cset->rhs=(double *)realloc(cset->rhs,sizeof(double)*cset->m);
    /* alpha=realloc(alpha,sizeof(double)*cset->m); */
    /* alphahist=realloc(alphahist,sizeof(long)*cset->m); */
  }
}


MATRIX *init_kernel_matrix(CONSTSET *cset, KERNEL_PARM *kparm) 
     /* assigns a kernelid to each constraint in cset and creates the
	corresponding kernel matrix. */
{
  int i,j;
  CFLOAT kval;
  MATRIX *matrix;

  /* assign kernel id to each new constraint */
  for(i=0;i<cset->m;i++) 
    cset->lhs[i]->kernelid=i;

  /* allocate kernel matrix as necessary */
  matrix=create_matrix(i+50,i+50);

  for(j=0;j<cset->m;j++) {
    for(i=j;i<cset->m;i++) {
      kval=kernel(kparm,cset->lhs[j],cset->lhs[i]);
      matrix->element[j][i]=kval;
      matrix->element[i][j]=kval;
    }
  }
  return(matrix);
}

MATRIX *update_kernel_matrix(MATRIX *matrix, int newpos, CONSTSET *cset, 
			     KERNEL_PARM *kparm) 
     /* assigns new kernelid to constraint in position newpos and
	fills the corresponding part of the kernel matrix */
{
  int i,maxkernelid=0,newid;
  CFLOAT kval;
  double *used;

  /* find free kernelid to assign to new constraint */
  for(i=0;i<cset->m;i++) 
    if(i != newpos)
      maxkernelid=MAX(maxkernelid,cset->lhs[i]->kernelid);
  used=create_nvector(maxkernelid+2);
  clear_nvector(used,maxkernelid+2);
  for(i=0;i<cset->m;i++) 
    if(i != newpos)
      used[cset->lhs[i]->kernelid]=1;
  for(newid=0;used[newid];newid++);
  free_nvector(used);
  cset->lhs[newpos]->kernelid=newid;

  /* extend kernel matrix if necessary */
  maxkernelid=MAX(maxkernelid,newid);
  if((!matrix) || (maxkernelid>=matrix->m))
    matrix=realloc_matrix(matrix,maxkernelid+50,maxkernelid+50);

  for(i=0;i<cset->m;i++) {
    kval=kernel(kparm,cset->lhs[newpos],cset->lhs[i]);
    matrix->element[newid][cset->lhs[i]->kernelid]=kval;
    matrix->element[cset->lhs[i]->kernelid][newid]=kval;
  }
  return(matrix);
}

CCACHE *create_constraint_cache(SAMPLE sample, STRUCT_LEARN_PARM *sparm)
     /* create new constraint cache for training set */
{
  long        n=sample.n;
  EXAMPLE     *ex=sample.examples;
  CCACHE      *ccache;
  int         i;

  ccache=(CCACHE *)malloc(sizeof(CCACHE));
  ccache->n=n;
  ccache->constlist=(CCACHEELEM **)malloc(sizeof(CCACHEELEM *)*n);
  for(i=0;i<n;i++) { 
    /* add constraint for ybar=y to cache */
    ccache->constlist[i]=(CCACHEELEM *)malloc(sizeof(CCACHEELEM));
    ccache->constlist[i]->fydelta=create_svector_n(NULL,0,"",1);
    ccache->constlist[i]->rhs=loss(ex[i].y,ex[i].y,sparm)/n;
    ccache->constlist[i]->viol=0;
    ccache->constlist[i]->next=NULL;
  }
  return(ccache);
}

void free_constraint_cache(CCACHE *ccache)
     /* frees all memory allocated for constraint cache */
{
  CCACHEELEM *celem,*next;
  int i;
  for(i=0; i<ccache->n; i++) {
    celem=ccache->constlist[i];
    while(celem) {
      free_svector(celem->fydelta);
      next=celem->next;
      free(celem);
      celem=next;
    }
  }
  free(ccache->constlist);
  free(ccache);
}

void add_constraint_to_constraint_cache(CCACHE *ccache, MODEL *svmModel, int exnum, SVECTOR *fydelta, double rhs, int maxconst)
     /* add new constraint fydelta*w>rhs for example exnum to cache,
	if it is more violated than the currently most violated
	constraint in cache. if this grows the number of constraint
	for this example beyond maxconst, then the most unused
	constraint is deleted. the funciton assumes that
	update_constraint_cache_for_model has been run. */
{
  double  viol;
  double  dist_ydelta;
  DOC     *doc_fydelta;
  CCACHEELEM *celem;
  int     cnum;

  doc_fydelta=create_example(1,0,1,1,fydelta);
  dist_ydelta=classify_example(svmModel,doc_fydelta);
  free_example(doc_fydelta,0);  
  viol=rhs-dist_ydelta;

  if((viol-0.000000000001) > ccache->constlist[exnum]->viol) {
    celem=ccache->constlist[exnum];
    ccache->constlist[exnum]=(CCACHEELEM *)malloc(sizeof(CCACHEELEM));
    ccache->constlist[exnum]->next=celem;
    ccache->constlist[exnum]->fydelta=fydelta;
    ccache->constlist[exnum]->rhs=rhs;
    ccache->constlist[exnum]->viol=viol;

    /* remove last constraint in list, if list is longer than maxconst */
    cnum=2;
    for(celem=ccache->constlist[exnum];celem && celem->next && celem->next->next;celem=celem->next)
      cnum++;
    if(cnum>maxconst) {
      free_svector(celem->next->fydelta);
      free(celem->next);
      celem->next=NULL;
    }
  }
  else {
    free_svector(fydelta);
  }
}

void update_constraint_cache_for_model(CCACHE *ccache, MODEL *svmModel)
     /* update the violation scores according to svmModel and find the
	most violated constraints for each example */
{ 
  int     i;
  double  progress=0,progress_old=0;
  double  maxviol=0;
  double  dist_ydelta;
  DOC     *doc_fydelta;
  CCACHEELEM *celem,*prev,*maxviol_celem,*maxviol_prev;

  for(i=0; i<ccache->n; i++) { /*** example loop ***/
	  
    progress+=10.0/ccache->n;
    if((struct_verbosity==1) && (((int)progress_old) != ((int)progress)))
      {printf("+");fflush(stdout); progress_old=progress;}
    if(struct_verbosity>=2)
      {printf("+"); fflush(stdout);}
    
    maxviol=0;
    prev=NULL;
    maxviol_celem=NULL;
    maxviol_prev=NULL;
    for(celem=ccache->constlist[i];celem;celem=celem->next) {
      doc_fydelta=create_example(1,0,1,1,celem->fydelta);
      dist_ydelta=classify_example(svmModel,doc_fydelta);
      free_example(doc_fydelta,0);
      celem->viol=celem->rhs-dist_ydelta;
      if((celem->viol > maxviol) || (!maxviol_celem)) {
	maxviol=celem->viol;
	maxviol_celem=celem;
	maxviol_prev=prev;
      }
      prev=celem;
    }
    if(maxviol_prev) { /* move max violated constraint to the top of list */
      maxviol_prev->next=maxviol_celem->next;
      maxviol_celem->next=ccache->constlist[i];
      ccache->constlist[i]=maxviol_celem;
    }
  }
}

double find_most_violated_joint_constraint_in_cache(CCACHE *ccache, SVECTOR **lhs, double *margin)
     /* constructs most violated joint constraint from cache. assumes
	that update_constraint_cache_for_model has been run. NOTE:
	this function returns only a shallow copy of the Psi vectors
	in lhs. So, do not use a deep free, otherwise the case becomes
	invalid. */
{
  double sumviol=0;
  int i;
  SVECTOR *fydelta;

  (*lhs)=NULL;
  (*margin)=0;

  /**** add all maximally violated fydelta to joint constraint ****/
  for(i=0; i<ccache->n; i++) { 
    fydelta=copy_svector_shallow(ccache->constlist[i]->fydelta);
    append_svector_list(fydelta,(*lhs));           /* add fydelta to lhs */
    (*lhs)=fydelta;
    (*margin)+=ccache->constlist[i]->rhs;   /* add loss to rhs */
    sumviol+=ccache->constlist[i]->viol;
  }

  return(sumviol);
}


double find_most_violated_joint_constraint_in_cache_old(int n, int cache_size, SVECTOR ***fydelta_cache, double **loss_cache, MODEL *svmModel, SVECTOR **lhs, double *margin)
{
  int     i,j;
  double  progress,progress_old;
  double  maxviol=0,sumviol,viol,lossval;
  double  dist_ydelta;
  SVECTOR *fydelta;
  DOC     *doc_fydelta;

  (*lhs)=NULL;
  (*margin)=0;
  sumviol=0;

  progress=0;
  progress_old=progress;

  for(i=0; i<n; i++) { /*** example loop ***/
	  
    progress+=10.0/n;
    if((struct_verbosity==1) && (((int)progress_old) != ((int)progress)))
      {printf("+");fflush(stdout); progress_old=progress;}
    if(struct_verbosity>=2)
      {printf("+"); fflush(stdout);}
    
    fydelta=NULL;
    lossval=0;
    for(j=0;j<cache_size;j++) {
      doc_fydelta=create_example(1,0,1,1,fydelta_cache[j][i]);
      dist_ydelta=classify_example(svmModel,doc_fydelta);
      free_example(doc_fydelta,0);

      viol=loss_cache[j][i]-dist_ydelta;
      if((viol > maxviol) || (!fydelta)) {
	fydelta=fydelta_cache[j][i];
	lossval=loss_cache[j][i];
	maxviol=viol;
      }
    }

    /**** add current fydelta to joint constraint ****/
    fydelta=copy_svector(fydelta);
    append_svector_list(fydelta,(*lhs));     /* add fydelta to lhs */
    (*lhs)=fydelta;
    (*margin)+=lossval;                      /* add loss to rhs */
    sumviol+=maxviol;
  }

  return(sumviol);
}
