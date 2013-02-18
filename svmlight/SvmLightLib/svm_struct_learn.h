/***********************************************************************/
/*                                                                     */
/*   svm_struct_learn.h                                                */
/*                                                                     */
/*   Basic algorithm for learning structured outputs (e.g. parses,     */
/*   sequences, multi-label classification) with a Support Vector      */ 
/*   Machine.                                                          */
/*                                                                     */
/*   Author: Thorsten Joachims                                         */
/*   Date: 03.07.04                                                    */
/*                                                                     */
/*   Copyright (c) 2004  Thorsten Joachims - All rights reserved       */
/*                                                                     */
/*   This software is available for non-commercial use only. It must   */
/*   not be modified and distributed without prior permission of the   */
/*   author. The author is not responsible for implications from the   */
/*   use of this software.                                             */
/*                                                                     */
/***********************************************************************/

#ifndef SVM_STRUCT_LEARN
#define SVM_STRUCT_LEARN

#ifdef __cplusplus
extern "C" {
#endif
#include "svm_common.h"
#include "svm_learn.h"
#ifdef __cplusplus
}
#endif
#include "svm_struct_common.h" 
#include "svm_struct_api_types.h" 

#define  SLACK_RESCALING    1
#define  MARGIN_RESCALING   2

#define  PRIMAL_ALG         2
#define  DUAL_ALG           3
#define  DUAL_CACHE_ALG     4

typedef struct ccacheelem {
  SVECTOR *fydelta; /* left hand side of constraint */
  double  rhs;      /* right hand side of constraint */
  double  viol;     /* violation score under current model */
  struct ccacheelem *next; /* next in linked list */
} CCACHEELEM;

typedef struct ccache {
  int        n;              /* number of examples */
  CCACHEELEM **constlist;    /* array of pointers to constraint lists
				- one list per example. The first
				element of the list always points to
				the most violated constraint under the
				current model for each example. */
} CCACHE;

CCACHE *create_constraint_cache(SAMPLE sample, STRUCT_LEARN_PARM *sparm);
void free_constraint_cache(CCACHE *ccache);
void add_constraint_to_constraint_cache(CCACHE *ccache, MODEL *svmModel, 
					int exnum, SVECTOR *fydelta, 
					double rhs, int maxconst);
void update_constraint_cache_for_model(CCACHE *ccache, MODEL *svmModel);
double find_most_violated_joint_constraint_in_cache(CCACHE *ccache, 
					SVECTOR **lhs, double *margin);
void svm_learn_struct(SAMPLE sample, STRUCT_LEARN_PARM *sparm,
		      LEARN_PARM *lparm, KERNEL_PARM *kparm, 
		      STRUCTMODEL *sm, HIDEO_ENV *hideo_env);
void svm_learn_struct_joint(SAMPLE sample, STRUCT_LEARN_PARM *sparm,
		      LEARN_PARM *lparm, KERNEL_PARM *kparm, 
		      STRUCTMODEL *sm, int alg_type, HIDEO_ENV *hideo_env);
void remove_inactive_constraints(CONSTSET *cset, double *alpha, 
			         long i, long *alphahist, long mininactive);
MATRIX *init_kernel_matrix(CONSTSET *cset, KERNEL_PARM *kparm); 
MATRIX *update_kernel_matrix(MATRIX *matrix, int newpos, CONSTSET *cset,
			     KERNEL_PARM *kparm);
 
#endif


