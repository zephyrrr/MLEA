#ifndef _EVAL_H
#define _EVAL_H

#include <stdio.h>
#include "linear.h"

#ifdef __cplusplus
extern "C" {
#endif

/* cross validation function */
double binary_class_cross_validation(const struct problem *prob, const struct parameter *param, int nr_fold);

/* predict function */
void binary_class_predict(FILE *input, FILE *output); 

extern struct model* model_;
void exit_input_error(int line_num);

#ifdef __cplusplus
}
#endif


#endif
