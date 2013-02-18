/*==========================================================================;
 *
 *  (c) 2007-09 mIHA.  All rights reserved.
 *
 *  File:          SvmLightLib.cpp
 *  Version:       1.0
 *  Desc:		   SVM^light and SVM^multiclass DLL wrapper
 *  Author:        Miha Grcar 
 *  Created on:    Aug-2007
 *  Last modified: Apr-2009 
 *  Revision:      Apr-2009
 *
 *  This software is available for non-commercial use only. It must not be 
 *  modified and distributed without prior permission of the author of 
 *  SVM^light and SVM^struct (Thorsten Joachims). None of the authors is
 *  responsible for implications from the use of this software.                                  
 * 
 ***************************************************************************/

#include <assert.h>
#include <map>
#include <fstream>
#include "Synchronize.h"
#include "SvmLightLib.h"

namespace SvmLight 
{
	extern "C" 
	{
		#include "svm_common.h"	
		#include "svm_struct_api_types.h"
		#include "svm_struct_api.h"
		#include "svm_struct_common.h"
		int svm_learn(int argc, char **argv, DOC **docs, double *label, long totwords, long totdoc, MODEL **model); // from svm_learn_main.c
		int _svm_learn(int argc, char **argv); // from svm_learn_main.c
		int _svm_classify(int argc, char **argv); // from svm_classify.c
		int svm_struct_learn(int argc, char **argv, SAMPLE *sample, STRUCTMODEL *model, STRUCT_LEARN_PARM *struct_parm); // from svm_struct_main.c
		int _svm_struct_learn(int argc, char **argv); // from svm_struct_main.c
		int _svm_struct_classify(int argc, char **argv); // from svm_struct_classify.c
		void write_struct_model(char *file, STRUCTMODEL *sm, STRUCT_LEARN_PARM *sparm); // from svm_struct_api.c
		STRUCTMODEL read_struct_model(char *file, STRUCT_LEARN_PARM *sparm); // from svm_struct_api.c
	}
}

using namespace SvmLight;
using namespace std;

#define LOCK(cs) CriticalSectionLock JOIN(lock_, __LINE__)(&cs)
#define DO_JOIN(a, b) a##b
#define JOIN(a, b) DO_JOIN(a, b)

struct Label
{
	double m_class_or_value;
	int m_num_scores;
	double *m_scores;
};

CriticalSection lock_feature_vectors;
CriticalSection lock_models;
CriticalSection lock_struct_models;

typedef pair<Label *, SVECTOR *> LabeledFeatureVector;
map<int, LabeledFeatureVector *> feature_vectors;
int feature_vector_id = 0;

map<int, MODEL *> models;
int model_id = 0;

typedef pair<STRUCTMODEL *, STRUCT_LEARN_PARM *> StructModelWithParams;
map<int, StructModelWithParams *> struct_models;
int struct_model_id = 0;

const char *FEATURE_VECTORS
	= "FeatureVectors";
const char *MODELS 
	= "Models";
const char *STRUCT_MODELS 
	= "StructModels";

LabeledFeatureVector *GetFeatureVector(int id)
{
	LOCK(lock_feature_vectors);
	return feature_vectors[id];
}

MODEL *GetModel(int id)
{
	LOCK(lock_models);
	return models[id];
}

StructModelWithParams *GetStructModelWithParams(int id)
{
	LOCK(lock_struct_models);
	return struct_models[id];
}

void ParseCommandLine(char *args, char ***argv, int *argc)
{
	int n = (int)strlen(args);
	int state = 0;
	*argc = 1;
	for (int i = 0; i < n; i++)
	{
		switch (state)
		{
			case 0:
				if (args[i] == '"') { state = 2; if (i + 1 < n && args[i + 1] != '"') { (*argc)++; } }
				else if (args[i] != '"' && args[i] != ' ') { state = 1; (*argc)++; }
				break;
			case 1:
				if (args[i] == ' ') { state = 0; }
				break;
			case 2:
				if (args[i] == '"') { state = 0; }
				break;
		}
	}
	*argv = new char*[(*argc) + 1];
	(*argv)[0] = NULL;
	(*argv)[*argc] = 0;
	state = 0;
	*argc = 1;
	for (int i = 0; i < n; i++)
	{
		switch (state)
		{
			case 0:
				if (args[i] == '"') { state = 2; if (i + 1 < n && args[i + 1] != '"') { (*argv)[*argc] = &args[i + 1]; (*argc)++; } }
				else if (args[i] != '"' && args[i] != ' ') { state = 1; (*argv)[*argc] = &args[i]; (*argc)++; }
				break;
			case 1:
				if (args[i] == ' ') { state = 0; args[i] = '\0'; }
				break;
			case 2:
				if (args[i] == '"') { state = 0; args[i] = '\0'; }
				break;
		}
	}
}

SVMLIGHTLIB_API int NewFeatureVector(int feature_count, int *features, float *weights, double _label)
{
	SVECTOR *feature_vector = new SVECTOR();
	feature_vector->userdefined = new char[1];
	feature_vector->userdefined[0] = 0;
	feature_vector->kernel_id = 0;
	feature_vector->next = NULL;
	feature_vector->factor = 1; 
	feature_vector->words = new SvmLight::WORD[feature_count + 1];
	for (int i = 0; i < feature_count; i++)
	{ 
		assert(features[i] > 0);
		feature_vector->words[i].wnum = features[i];
		feature_vector->words[i].weight = weights[i];
	}
	feature_vector->words[feature_count].wnum = 0;
	feature_vector->twonorm_sq = -1;
	Label *label = new Label();
	label->m_class_or_value = _label;
	label->m_num_scores = -1;
	label->m_scores = NULL;
	LOCK(lock_feature_vectors);
	feature_vector_id++;
	feature_vectors.insert(pair<int, LabeledFeatureVector *>(feature_vector_id, new LabeledFeatureVector(label, feature_vector)));
	return feature_vector_id;
}

SVMLIGHTLIB_API void DeleteFeatureVector(int id)
{
	LOCK(lock_feature_vectors);
	LabeledFeatureVector *feature_vector = feature_vectors[id];
	delete[] feature_vector->second->userdefined;
	delete[] feature_vector->second->words; 
	delete feature_vector->second;
	delete[] feature_vector->first->m_scores;
	delete feature_vector->first;
	feature_vectors.erase(id);
}

SVMLIGHTLIB_API int GetFeatureVectorFeatureCount(int feature_vector_id)
{
	LabeledFeatureVector *feature_vector = GetFeatureVector(feature_vector_id);
	int count = 0;
	while (feature_vector->second->words[count].wnum) { count++; }
	return count;
}

SVMLIGHTLIB_API int GetFeatureVectorFeature(int feature_vector_id, int feature_idx)
{
	LabeledFeatureVector *feature_vector = GetFeatureVector(feature_vector_id);
	return feature_vector->second->words[feature_idx].wnum;
}

SVMLIGHTLIB_API float GetFeatureVectorWeight(int feature_vector_id, int feature_idx)
{
	LabeledFeatureVector *feature_vector = GetFeatureVector(feature_vector_id);
	return feature_vector->second->words[feature_idx].weight; 
}

SVMLIGHTLIB_API double GetFeatureVectorLabel(int feature_vector_id)
{
	LabeledFeatureVector *feature_vector = GetFeatureVector(feature_vector_id);
	return feature_vector->first->m_class_or_value;
}

SVMLIGHTLIB_API void SetFeatureVectorLabel(int feature_vector_id, double label)
{
	LabeledFeatureVector *feature_vector = GetFeatureVector(feature_vector_id);
	feature_vector->first->m_class_or_value = label;
}

SVMLIGHTLIB_API int GetFeatureVectorClassifScoreCount(int feature_vector_id)
{
	LabeledFeatureVector *feature_vector = GetFeatureVector(feature_vector_id);
	return feature_vector->first->m_num_scores;
}

SVMLIGHTLIB_API double GetFeatureVectorClassifScore(int feature_vector_id, int classif_score_idx) 
{
	LabeledFeatureVector *feature_vector = GetFeatureVector(feature_vector_id);
	return feature_vector->first->m_scores[classif_score_idx];
}

SVMLIGHTLIB_API void _TrainModel(char *_args)
{
	// parse command line
	int argc;
	char *args = _strdup(_args);
	char **argv;
	ParseCommandLine(args, &argv, &argc);
	// learn
	_svm_learn(argc, argv);
	// cleanup
	delete[] argv;
	free(args);
}

SVMLIGHTLIB_API int TrainModel(char *_args, int feature_vector_count, int *feature_vectors)
{
	int argc;
	char *args = _strdup(_args);
	char **argv;
	ParseCommandLine(args, &argv, &argc);
	// learn 
	MODEL *model;
	int totwords = 0;
	int totdoc = feature_vector_count;
	DOC **docs = new DOC *[totdoc];
	double *label = new double[totdoc];
	// initialize totwords, docs, and label
	for (int i = 0; i < totdoc; i++)
	{
		LabeledFeatureVector *_feature_vector = GetFeatureVector(feature_vectors[i]);
		SVECTOR *feature_vector = _feature_vector->second;
		docs[i] = new DOC();
		docs[i]->docnum = i;
		docs[i]->costfactor = 1;
		docs[i]->queryid = 0;
		docs[i]->slackid = 0;
		docs[i]->kernelid = i;
		docs[i]->fvec = feature_vector;
		label[i] = _feature_vector->first->m_class_or_value;
		int j = 0;
		while (feature_vector->words[j].wnum) 
		{
			if (feature_vector->words[j].wnum > totwords) { totwords = feature_vector->words[j].wnum; }
			j++;
		}
	}
	int ret_val = svm_learn(argc, argv, docs, label, totwords, totdoc, &model);
	if (ret_val == 0)
	{
		if (model->kernel_parm.kernel_type == LINEAR && !model->lin_weights) 
		{ 
			add_weight_vector_to_linear_model(model); 
		}
		// register the model		
		{
			LOCK(lock_models);
			model_id++;
			ret_val = model_id;
			models.insert(pair<int, MODEL *>(model_id, model));
		}
		if (model->n_td_pred > 0) // transductive learning was performed; assign scores to the training set labels
		{
			int j = 0;
			for (int i = 0; i < totdoc; i++)
			{
				LabeledFeatureVector *feature_vector = GetFeatureVector(feature_vectors[i]);
				feature_vector->first->m_scores = new double[1];
				feature_vector->first->m_num_scores = 1;
				if (feature_vector->first->m_class_or_value == 0)
				{					
					feature_vector->first->m_scores[0] = model->td_pred[j++];
				}
				else
				{
					feature_vector->first->m_scores[0] = feature_vector->first->m_class_or_value == 1 ? 9999 : -9999;
				}
			}
		}
	}
	// cleanup 
	delete[] argv;
	free(args);
	delete[] label;
	for (int i = 0; i < totdoc; i++) { delete docs[i]; }
	delete[] docs;
	// return model ID or -1 if error occurred
	return ret_val;
}

SVMLIGHTLIB_API void SaveModel(int model_id, char *file_name)
{
	MODEL *model = GetModel(model_id);
	write_model(file_name, model);
}

SVMLIGHTLIB_API int LoadModel(char *file_name)
{
	MODEL *model = read_model(file_name);
	// register the model
	{
		LOCK(lock_models);
		model_id++;
		models.insert(pair<int, MODEL *>(model_id, model));
	}
	return model_id;
}

SVMLIGHTLIB_API void SaveModelBin(int model_id, char *file_name) // modified write_model
{
	MODEL *model = GetModel(model_id);
    ofstream model_file;
	model_file.open(file_name, ios::out | ios::binary);
	if (!model_file.is_open())
	{
		perror(file_name);
		exit(1);
	}	
	int ver_len = (int)strlen(VERSION);
	model_file.write((const char *)&ver_len, sizeof(int));
	model_file.write(VERSION, ver_len);
	model_file.write((const char *)&model->kernel_parm.kernel_type, sizeof(long));
	model_file.write((const char *)&model->kernel_parm.poly_degree, sizeof(long));
	model_file.write((const char *)&model->kernel_parm.rbf_gamma, sizeof(double));
	model_file.write((const char *)&model->kernel_parm.coef_lin, sizeof(double));
	model_file.write((const char *)&model->kernel_parm.coef_const, sizeof(double));
	model_file.write((const char *)&model->kernel_parm.custom, 50);
	model_file.write((const char *)&model->totwords, sizeof(long));
	model_file.write((const char *)&model->totdoc, sizeof(long));
	int sv_num = 1;
	for (int i = 1; i < model->sv_num; i++)
	{
		for (SVECTOR *vec = model->supvec[i]->fvec; vec; vec = vec->next)
		{
			sv_num++;
		}
	}
	model_file.write((const char *)&sv_num, sizeof(int));
	model_file.write((const char *)&model->b, sizeof(double));
	for (int i = 1; i < model->sv_num; i++)
	{
		for (SVECTOR *vec = model->supvec[i]->fvec; vec; vec = vec->next)
		{
			double tmp = model->alpha[i] * vec->factor;
			model_file.write((const char *)&tmp, sizeof(double));
			int num_feat = 0;
			for (int j = 0; vec->words[j].wnum; j++) { num_feat++; }
			model_file.write((const char *)&num_feat, sizeof(int));
			for (int j = 0; vec->words[j].wnum; j++)
			{				
				model_file.write((const char *)&vec->words[j].wnum, sizeof(FNUM));
				model_file.write((const char *)&vec->words[j].weight, sizeof(FVAL)); 
			}
			int len = (int)strlen(vec->userdefined);
			model_file.write((const char *)&len, sizeof(int));
			model_file.write(vec->userdefined, len);
		}
    }
	model_file.close();
}

SVMLIGHTLIB_API int LoadModelBin(char *file_name) // modified read_model
{
	ifstream model_file;
	model_file.open(file_name, ios::in | ios::binary);
	if (!model_file.is_open())
	{
		perror(file_name);
		exit(1);
	}
	int ver_len;
	model_file.read((char *)&ver_len, sizeof(int));
	char *version = new char[ver_len + 1];
	model_file.read(version, ver_len);
	version[ver_len] = 0;
	if (strcmp(version, VERSION))
	{
		perror("Version of model-file does not match version of svm_classify!");
		exit(1);
	}
	delete[] version;
	MODEL *model = (MODEL *)my_malloc(sizeof(MODEL));
	model->n_td_pred = 0;
	model->td_pred = NULL;
	model_file.read((char *)&model->kernel_parm.kernel_type, sizeof(long));
	model_file.read((char *)&model->kernel_parm.poly_degree, sizeof(long));
	model_file.read((char *)&model->kernel_parm.rbf_gamma, sizeof(double));
	model_file.read((char *)&model->kernel_parm.coef_lin, sizeof(double));
	model_file.read((char *)&model->kernel_parm.coef_const, sizeof(double));
	model_file.read((char *)&model->kernel_parm.custom, 50);
	model_file.read((char *)&model->totwords, sizeof(long));
	model_file.read((char *)&model->totdoc, sizeof(long));
	model->sv_num = 0L;
	model_file.read((char *)&model->sv_num, sizeof(int));
	model_file.read((char *)&model->b, sizeof(double));
	model->supvec = (DOC **)my_malloc(sizeof(DOC *) * model->sv_num);
	model->alpha = (double *)my_malloc(sizeof(double) * model->sv_num);
	model->index = NULL;
	model->lin_weights = NULL;
	for (int i = 1; i < model->sv_num; i++)
	{
		int num_feat;
		model_file.read((char *)&model->alpha[i], sizeof(double));
		model_file.read((char *)&num_feat, sizeof(int));
		SvmLight::WORD *words = (SvmLight::WORD *)my_malloc(sizeof(SvmLight::WORD) * (num_feat + 1));
		for (int j = 0; j < num_feat; j++)
		{
			model_file.read((char *)&words[j].wnum, sizeof(FNUM));
			model_file.read((char *)&words[j].weight, sizeof(FVAL)); 
		}
		words[num_feat].wnum = 0;
		int comment_len;		
		model_file.read((char *)&comment_len, sizeof(int));
		char *comment = new char[comment_len + 1];
		model_file.read(comment, comment_len);
		comment[comment_len] = 0;
		model->supvec[i] = create_example(-1, 0, 0, 0.0, create_svector(words, comment, 1.0));
		delete[] comment;
	}
	model_file.close();
	if (verbosity >= 1)
	{
		fprintf(stdout, "OK. (%d support vectors read)\n", (int)(model->sv_num - 1));
	}
	// register the model
	{
		LOCK(lock_models);
		model_id++;
		models.insert(pair<int, MODEL *>(model_id, model));
	}
	return model_id;
}

SVMLIGHTLIB_API void _Classify(char *_args)
{
	// parse command line
	int argc;
	char *args = _strdup(_args);
	char **argv;
	ParseCommandLine(args, &argv, &argc);
	// learn
	_svm_classify(argc, argv);
	// cleanup
	delete[] argv;
	free(args);
}

SVMLIGHTLIB_API void Classify(int model_id, int feature_vector_count, int *feature_vectors)
{
	MODEL *model = GetModel(model_id);
	if (model->kernel_parm.kernel_type == LINEAR && !model->lin_weights)
	{
		add_weight_vector_to_linear_model(model); 
	}
	for (int i = 0; i < feature_vector_count; i++)
	{
		LabeledFeatureVector *feature_vector = GetFeatureVector(feature_vectors[i]);
		if (model->kernel_parm.kernel_type == LINEAR) // linear kernel
		{
			SvmLight::WORD *word;
			for (int j = 0; (word = &feature_vector->second->words[j])->wnum != 0; j++)
			{
				assert(word->wnum <= model->totwords);
				if (word->wnum > model->totwords) { word->wnum = 0; }
			}
			DOC *doc = create_example(-1, 0, 0, 0, feature_vector->second);
			double dist = classify_example_linear(model, doc);			
			delete[] feature_vector->first->m_scores; 
			feature_vector->first->m_scores = new double[1];
			feature_vector->first->m_scores[0] = dist;
			feature_vector->first->m_num_scores = 1;
			free_example(doc, 0);
		}
		else // non-linear kernel
		{
			DOC *doc = create_example(-1, 0, 0, 0, feature_vector->second);
			double dist = classify_example(model, doc);
			delete[] feature_vector->first->m_scores; 
			feature_vector->first->m_scores = new double[1];
			feature_vector->first->m_scores[0] = dist;
			feature_vector->first->m_num_scores = 1;
			free_example(doc, 0);
		}
	}
}

SVMLIGHTLIB_API void DeleteModel(int id)
{
	LOCK(lock_models);
	MODEL *model = models[id];
	free_model(model, 1);
	models.erase(id);
}

SVMLIGHTLIB_API void _TrainMulticlassModel(char *_args)
{
	// parse command line
	int argc;
	char *args = _strdup(_args);
	char **argv;
	ParseCommandLine(args, &argv, &argc);
	// learn
	_svm_struct_learn(argc, argv);
	// cleanup
	delete[] argv;
	free(args);
}

SVMLIGHTLIB_API int TrainMulticlassModel(char *_args, int feature_vector_count, int *feature_vectors)
{
	int argc;
	char *args = _strdup(_args);
	char **argv;
	ParseCommandLine(args, &argv, &argc);
	// learn 
	STRUCTMODEL *model = new STRUCTMODEL();
	SAMPLE sample;
	sample.n = feature_vector_count;
	sample.examples = new EXAMPLE[sample.n];
	int num_classes = 0;
	for (int i = 0; i < sample.n; i++)
	{
		int label = (int)GetFeatureVector(feature_vectors[i])->first->m_class_or_value;
		if (label > num_classes) { num_classes = label; }
	}
	for (int i = 0; i < sample.n; i++)
	{
		LabeledFeatureVector *_feature_vector = GetFeatureVector(feature_vectors[i]);
		SVECTOR *feature_vector = _feature_vector->second;
		sample.examples[i].x.doc = new DOC();
		sample.examples[i].x.doc->docnum = i;
		sample.examples[i].x.doc->costfactor = 1;
		sample.examples[i].x.doc->queryid = 0;
		sample.examples[i].x.doc->slackid = 0;
		sample.examples[i].x.doc->kernelid = i;
		sample.examples[i].x.doc->fvec = feature_vector;
		sample.examples[i].y._class = (int)_feature_vector->first->m_class_or_value;
		sample.examples[i].y.num_classes = num_classes;
		sample.examples[i].y.scores = NULL;
	}
	STRUCT_LEARN_PARM *params = new STRUCT_LEARN_PARM();
	svm_struct_learn(argc, argv, &sample, model, params);
	// register the model
	{
		LOCK(lock_struct_models);
		struct_model_id++;
		struct_models.insert(pair<int, StructModelWithParams *>(struct_model_id, new StructModelWithParams(model, params)));
	}
	// cleanup 
	delete[] argv;
	free(args);
	for (int i = 0; i < sample.n; i++)
	{
		delete sample.examples[i].x.doc;
	}	
	delete[] sample.examples;
	// return model ID
	return struct_model_id;
}

SVMLIGHTLIB_API void SaveMulticlassModel(int model_id, char *file_name)
{
	StructModelWithParams *model_with_params = GetStructModelWithParams(model_id);
	STRUCTMODEL *model = model_with_params->first;
	STRUCT_LEARN_PARM *params = model_with_params->second;
	write_struct_model(file_name, model, params);
}

SVMLIGHTLIB_API int LoadMulticlassModel(char *file_name)
{
	STRUCTMODEL *model = new STRUCTMODEL();
	STRUCT_LEARN_PARM *params = new STRUCT_LEARN_PARM();
	STRUCTMODEL model_tmp = read_struct_model(file_name, params);
	model->sizePsi = model_tmp.sizePsi;
	model->w = model_tmp.w;
	model->svm_model = model_tmp.svm_model;
	// register the model
	{
		LOCK(lock_struct_models);
		struct_model_id++;
		struct_models.insert(pair<int, StructModelWithParams *>(struct_model_id, new StructModelWithParams(model, params)));
	}
	return struct_model_id;
}

SVMLIGHTLIB_API void SaveMulticlassModelBin(int model_id, char *file_name) // modified write_struct_model
{
	StructModelWithParams *model_with_params = GetStructModelWithParams(model_id);
	STRUCTMODEL *model = model_with_params->first;
	MODEL *svm_model = model->svm_model;
	STRUCT_LEARN_PARM *params = model_with_params->second;
	ofstream model_file;
	model_file.open(file_name, ios::out | ios::binary);
	if (!model_file.is_open())
	{
		perror(file_name);
		exit(1);
	}
	int ver_len = (int)strlen(INST_VERSION);
	model_file.write((const char *)&ver_len, sizeof(int));
	model_file.write(INST_VERSION, ver_len);
	model_file.write((const char *)&params->num_classes, sizeof(int));
	model_file.write((const char *)&params->num_features, sizeof(int));
	model_file.write((const char *)&params->loss_function, sizeof(int));
	model_file.write((const char *)&svm_model->kernel_parm.kernel_type, sizeof(long));
	model_file.write((const char *)&svm_model->kernel_parm.poly_degree, sizeof(long));
	model_file.write((const char *)&svm_model->kernel_parm.rbf_gamma, sizeof(double));
	model_file.write((const char *)&svm_model->kernel_parm.coef_lin, sizeof(double));
	model_file.write((const char *)&svm_model->kernel_parm.coef_const, sizeof(double));
	model_file.write((const char *)&svm_model->kernel_parm.custom, 50);
	model_file.write((const char *)&svm_model->totwords, sizeof(long));
	model_file.write((const char *)&svm_model->totdoc, sizeof(long));
	int sv_num = 1;
	SVECTOR *vec;
	for (int i = 1; i < svm_model->sv_num; i++)
	{
		for (vec = svm_model->supvec[i]->fvec; vec; vec = vec->next)
		{
			sv_num++;
		}
	}
	model_file.write((const char *)&sv_num, sizeof(int));
	model_file.write((const char *)&svm_model->b, sizeof(double));
	for (int i = 1; i < svm_model->sv_num; i++)
	{
		for (vec = svm_model->supvec[i]->fvec; vec; vec = vec->next)
		{
			double alpha_times_factor = svm_model->alpha[i] * vec->factor;
			model_file.write((const char *)&alpha_times_factor, sizeof(double));
			int num_feat = 0;
			for (int j = 0; vec->words[j].wnum; j++) { num_feat++; }
			model_file.write((const char *)&num_feat, sizeof(int));
			for (int j = 0; vec->words[j].wnum; j++)
			{
				model_file.write((const char *)&vec->words[j].wnum, sizeof(FNUM));
				model_file.write((const char *)&vec->words[j].weight, sizeof(FVAL)); 
			}
			int len = (int)strlen(vec->userdefined);
			model_file.write((const char *)&len, sizeof(int));
			model_file.write(vec->userdefined, len);
		}
	}
	model_file.close();
}

SVMLIGHTLIB_API int LoadMulticlassModelBin(char *file_name) // modified read_struct_model
{
	STRUCTMODEL *model = new STRUCTMODEL();
	STRUCT_LEARN_PARM *params = new STRUCT_LEARN_PARM();
	ifstream model_file;
	model_file.open(file_name, ios::in | ios::binary);
	if (!model_file.is_open())
	{
		perror(file_name);
		exit(1);
	}
	int ver_len;
	model_file.read((char *)&ver_len, sizeof(int));
	char *version = new char[ver_len + 1];
	model_file.read(version, ver_len);
	version[ver_len] = 0;
	if (strcmp(version, INST_VERSION))
	{
		perror("Version of model-file does not match version of svm_struct_classify!");
		exit(1);
	}
	delete[] version;
	MODEL *svm_model = (MODEL *)my_malloc(sizeof(MODEL));
	svm_model->n_td_pred = 0;
	svm_model->td_pred = NULL;
	model_file.read((char *)&params->num_classes, sizeof(int));
	model_file.read((char *)&params->num_features, sizeof(int));
	model_file.read((char *)&params->loss_function, sizeof(int));
	model_file.read((char *)&svm_model->kernel_parm.kernel_type, sizeof(long));
	model_file.read((char *)&svm_model->kernel_parm.poly_degree, sizeof(long));
	model_file.read((char *)&svm_model->kernel_parm.rbf_gamma, sizeof(double));
	model_file.read((char *)&svm_model->kernel_parm.coef_lin, sizeof(double));
	model_file.read((char *)&svm_model->kernel_parm.coef_const, sizeof(double));
	model_file.read((char *)&svm_model->kernel_parm.custom, 50);
	model_file.read((char *)&svm_model->totwords, sizeof(long));
	model_file.read((char *)&svm_model->totdoc, sizeof(long));
	svm_model->sv_num = 0L;
	model_file.read((char *)&svm_model->sv_num, sizeof(int));
	model_file.read((char *)&svm_model->b, sizeof(double));
	svm_model->supvec = (DOC **)my_malloc(sizeof(DOC *) * svm_model->sv_num);
	svm_model->alpha = (double *)my_malloc(sizeof(double) * svm_model->sv_num);
	svm_model->index = NULL;
	svm_model->lin_weights = NULL;	
	for (int i = 1; i < svm_model->sv_num; i++)
	{
		int num_feat;
		model_file.read((char *)&svm_model->alpha[i], sizeof(double));
		model_file.read((char *)&num_feat, sizeof(int));
		SvmLight::WORD *words = (SvmLight::WORD *)my_malloc(sizeof(SvmLight::WORD) * (num_feat + 1));
		for (int j = 0; j < num_feat; j++)
		{
			model_file.read((char *)&words[j].wnum, sizeof(FNUM));
			model_file.read((char *)&words[j].weight, sizeof(FVAL)); 
		}
		words[num_feat].wnum = 0;
		int comment_len;		
		model_file.read((char *)&comment_len, sizeof(int));
		char *comment = new char[comment_len + 1];
		model_file.read(comment, comment_len);
		comment[comment_len] = 0;
		svm_model->supvec[i] = create_example(-1, 0, 0, 0.0, create_svector(words, comment, 1.0));
		delete[] comment;
	}
	model_file.close();
	if (verbosity >= 1)
	{
		fprintf(stdout, " (%d support vectors read) ", (int)(svm_model->sv_num - 1));
	}
	model->svm_model = svm_model;
	model->sizePsi = svm_model->totwords;
	model->w = NULL;
	// register the model
	{
		LOCK(lock_struct_models);
		struct_model_id++;
		struct_models.insert(pair<int, StructModelWithParams *>(struct_model_id, new StructModelWithParams(model, params)));
	}
	return struct_model_id;
}

SVMLIGHTLIB_API void _MulticlassClassify(char *_args)
{
	// parse command line
	int argc;
	char *args = _strdup(_args);
	char **argv;
	ParseCommandLine(args, &argv, &argc);
	// learn
	_svm_struct_classify(argc, argv);
	// cleanup
	delete[] argv;
	free(args);
}

SVMLIGHTLIB_API void MulticlassClassify(int model_id, int feature_vector_count, int *feature_vectors)
{
	StructModelWithParams *model_with_params = GetStructModelWithParams(model_id);
	STRUCTMODEL *model = model_with_params->first;
	STRUCT_LEARN_PARM *params = model_with_params->second;
	if (model->svm_model->kernel_parm.kernel_type == LINEAR && !model->svm_model->lin_weights)
	{
		add_weight_vector_to_linear_model(model->svm_model); 
		model->w = model->svm_model->lin_weights;
	}
	SAMPLE test_sample;
	test_sample.n = feature_vector_count;
	test_sample.examples = new EXAMPLE[test_sample.n];
	for (int i = 0; i < test_sample.n; i++)
	{
		LabeledFeatureVector *_feature_vector = GetFeatureVector(feature_vectors[i]);
		SVECTOR *feature_vector = _feature_vector->second;
		test_sample.examples[i].x.doc = new DOC();
		test_sample.examples[i].x.doc->docnum = i;
		test_sample.examples[i].x.doc->costfactor = 1;
		test_sample.examples[i].x.doc->queryid = 0;
		test_sample.examples[i].x.doc->slackid = 0;
		test_sample.examples[i].x.doc->kernelid = i;
		test_sample.examples[i].x.doc->fvec = feature_vector;
		test_sample.examples[i].y._class = (int)_feature_vector->first->m_class_or_value;
		test_sample.examples[i].y.num_classes = params->num_classes;
		test_sample.examples[i].y.scores = NULL;
	}
	for (int i = 0; i < test_sample.n; i++)
	{
		LabeledFeatureVector *feature_vector = GetFeatureVector(feature_vectors[i]);
		LABEL y = classify_struct_example(test_sample.examples[i].x, model, params);
		feature_vector->first->m_num_scores = y.num_classes;
		delete[] feature_vector->first->m_scores; 
		feature_vector->first->m_scores = new double[y.num_classes];
		memcpy(feature_vector->first->m_scores, &y.scores[1], y.num_classes * sizeof(double));
		delete[] y.scores;
	}
	for (int i = 0; i < test_sample.n; i++)
	{
		delete test_sample.examples[i].x.doc;
	}	
	delete[] test_sample.examples;
}

SVMLIGHTLIB_API void DeleteMulticlassModel(int id)
{
	LOCK(lock_struct_models);
	StructModelWithParams *model_with_params = struct_models[id];
	STRUCTMODEL *model = model_with_params->first;
	STRUCT_LEARN_PARM *params = model_with_params->second;
	free_struct_model(*model);
	delete model;
	delete params;
	delete model_with_params;
	struct_models.erase(id);
}