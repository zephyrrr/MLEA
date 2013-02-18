/*==========================================================================;
 *
 *  (c) 2007-09 mIHA.  All rights reserved.
 *
 *  File:          SvmLightLib.h
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

#ifndef SVMLIGHTLIB_H
#define SVMLIGHTLIB_H

#ifdef SVMLIGHTLIB_EXPORTS
#define SVMLIGHTLIB_API extern "C" __declspec(dllexport)
#else
#define SVMLIGHTLIB_API extern "C" __declspec(dllimport)
#endif

// label is 1 or -1 for inductive binary SVM; 1, -1, or 0 (unlabeled) for transductive binary SVM; 
// a positive integer for multiclass SVM; a real value for SVM regression
SVMLIGHTLIB_API int NewFeatureVector(int feature_count, int *features, float *weights, double label);
SVMLIGHTLIB_API void DeleteFeatureVector(int id);
SVMLIGHTLIB_API int GetFeatureVectorFeatureCount(int feature_vector_id);
SVMLIGHTLIB_API int GetFeatureVectorFeature(int feature_vector_id, int feature_idx);
SVMLIGHTLIB_API float GetFeatureVectorWeight(int feature_vector_id, int feature_idx);
SVMLIGHTLIB_API double GetFeatureVectorLabel(int feature_vector_id);
SVMLIGHTLIB_API void SetFeatureVectorLabel(int feature_vector_id, double label);
SVMLIGHTLIB_API int GetFeatureVectorClassifScoreCount(int feature_vector_id);
SVMLIGHTLIB_API double GetFeatureVectorClassifScore(int feature_vector_id, int classif_score_idx);

SVMLIGHTLIB_API void _TrainModel(char *args);
SVMLIGHTLIB_API int TrainModel(char *args, int feature_vector_count, int *feature_vectors);
SVMLIGHTLIB_API void SaveModel(int model_id, char *file_name);
SVMLIGHTLIB_API int LoadModel(char *file_name);
SVMLIGHTLIB_API void SaveModelBin(int model_id, char *file_name);
SVMLIGHTLIB_API int LoadModelBin(char *file_name);
SVMLIGHTLIB_API void _Classify(char *args);
SVMLIGHTLIB_API void Classify(int model_id, int feature_vector_count, int *feature_vectors);
SVMLIGHTLIB_API void DeleteModel(int id);

SVMLIGHTLIB_API void _TrainMulticlassModel(char *args);
SVMLIGHTLIB_API int TrainMulticlassModel(char *args, int feature_vector_count, int *feature_vectors);
SVMLIGHTLIB_API void SaveMulticlassModel(int model_id, char *file_name);
SVMLIGHTLIB_API int LoadMulticlassModel(char *file_name);
SVMLIGHTLIB_API void SaveMulticlassModelBin(int model_id, char *file_name);
SVMLIGHTLIB_API int LoadMulticlassModelBin(char *file_name);
SVMLIGHTLIB_API void _MulticlassClassify(char *args);
SVMLIGHTLIB_API void MulticlassClassify(int model_id, int feature_vector_count, int *feature_vectors);
SVMLIGHTLIB_API void DeleteMulticlassModel(int id);

#endif