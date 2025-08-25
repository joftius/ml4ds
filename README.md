# Under construction...

## Lectures

#### Week 1 simple prediction



#### Week 2 regression



#### Week 3 causality



#### Week 4 classification



####  Week 5 optimization



#### Week 6

reading week

####  Week 7 validation



####  Week 8 high-dimensional regression



#### Week 9 additive models



#### Week 10 tree-based models



#### Week 11 interpretation and causal redux



## Seminar notebooks

Here are links to all the current versions of notebooks. The _complete versions are for teachers' reference and should not be used by students. Every .html link can be edited to .Rmd to download the source.

#### Week 1 simple prediction

https://ml4ds.com/weeks/01-introduction-foundations/notebooks/notebook1.html

https://ml4ds.com/weeks/01-introduction-foundations/notebooks/notebook1_complete.html

Extra: https://ml4ds.com/weeks/01-introduction-foundations/notebooks/candy.html

#### Week 2 regression

https://ml4ds.com/weeks/02-linear-regression/notebooks/regression_complete.html

https://ml4ds.com/weeks/02-linear-regression/notebooks/seminar_regression.html

#### Week 3 causality

https://ml4ds.com/weeks/03-causality/notebooks/regression_causality.html

Week 3 update idea:  I might suggest going off-script and doing something to emphasize the differences in causal models, right after the direct causation X -> Y example you can do reverse causation X <- Y. The point would be to see that an ML model can still predict Y from X, but if people use that model because they're hoping to change Y by intervening on X then they will be disappointed

#### Week 4 classification

https://ml4ds.com/weeks/04-classification/notebooks/classification_complete.html

https://ml4ds.com/weeks/03-causality/notebooks/logistic_regression_fresh.html

https://ml4ds.com/weeks/03-causality/notebooks/logistic_regression.html

####  Week 5 optimization

https://ml4ds.com/weeks/04-classification/notebooks/gradient_descent.html

https://ml4ds.com/weeks/05-optimization/notebooks/optimization_incomplete.html

https://ml4ds.com/weeks/05-optimization/notebooks/SGD_complete.html

#### Week 6

reading week

####  Week 7 validation

https://ml4ds.com/weeks/06-regularization/notebooks/validation_complete.html

####  Week 8 high-dimensional regression

https://ml4ds.com/weeks/07-highdim/notebooks/lasso_estimation.html

https://ml4ds.com/weeks/07-highdim/notebooks/lasso_inference_complete.html

#### Week 9 additive models

https://ml4ds.com/weeks/08-additive/notebooks/GAMs_complete.html

#### Week 10 tree-based models

https://ml4ds.com/weeks/09-trees/notebooks/tree_splits_complete.html

#### Week 11 interpretation and causal redux

https://ml4ds.com/weeks/10-action/notebooks/iml_complete.html

#### Extras / deprecated

https://ml4ds.com/weeks/05-optimization/notebooks/generalization_incomplete.html

https://ml4ds.com/weeks/05-optimization/notebooks/regularization_incomplete.html

https://ml4ds.com/weeks/08-additive/notebooks/knn_complete.html

https://ml4ds.com/weeks/08-additive/notebooks/nonlinear_knn_incomplete.html

https://ml4ds.com/weeks/08-additive/notebooks/kernel_complete.html

https://ml4ds.com/weeks/08-additive/notebooks/ksvm_complete.html

## Announcements

#### Pre-term

If you are not yet experienced with using the R statistical programming language it is highly recommended that you self-enroll in one of the following pre-sessional courses from the Digital Skills Lab:

https://moodle.lse.ac.uk/course/view.php?id=8714

https://moodle.lse.ac.uk/course/view.php?id=8687

(These links might be outdated, but you should be able to find the most recent term on Moodle)

I have one other important request in case you need to contact me before the first lecture. As a courtesy to me, please don't use any "AI" tools in our communications. This also applies to all aspects of this course. We are here to train our own minds, not to replace them.

#### Week 1 simple prediction

Required reading

In this course, there is required reading before each week's lectures and classes. For Week 1:

-    ISLR Chapter 1: Introduction. Should be a quick read. Don’t skip the section on Notation and Simple Matrix Algebra.
-    ISLR Chapter 2: Statistical Learning.

If you finish these quickly you may want to start Chapter 3, because it’s a long one.
Class preparation

Remember to bring your laptop to the class for your seminar group, and take the time to set up R and RStudio in advance. More info about this follows at the end of the message (because it's long)

Computer preparation

R is the recommended language for this course because we will use some packages that are, to my knowledge, only available in R. If you prefer Python you can probably do much of the work that way, but I may not be able to help with troubleshooting. Fortunately, both languages can be used from within the other, so you can switch between them as needed if you have a strong preference for Python.

This page explains how to install R and RStudio, follow the instructions here if you don't already have these programs on your computer: https://rstudio-education.github.io/hopr/starting.html

(If you use the Homebrew package manager you can also install from that quite easily https://dani.gg/en/install-r-and-rstudio-with-homebrew-on-macos/ with a few quick commands)

After installing R and then RStudio, you should also open RStudio and install some packages. To get started I suggest installing certain packages that we'll use in advance in case you run into any errors in the process. You can do this by running the command:

`install.packages(c("tidyverse", "rmarkdown", "knitr", "plotly", "ggthemes", "viridis", "glmnet", "tidymodels", "ISLR", "modeldata"))`

If you are interested in finding out about more of the most useful R packages there are some great suggestions here: https://support.rstudio.com/hc/en-us/articles/201057987-Quick-list-of-useful-R-packages -- we may end up installing other packages throughout the term.

Note that LSE has daily online drop-in sessions where you can get help with R: https://info.lse.ac.uk/current-students/digital-skills-lab/r

#### Week 2 regression

Required reading

    ISLR Chapter 3: Linear Regression.

This chapter is long but should be mostly a review of material from previous courses.
Supplemental reading

    ESL corresponding chapters
    MLstory Fundamentals of prediction and Supervised learning chapters

Computer setup

Identify a dataset that you can use to fit a multiple regression model (one outcome variable, multiple predictor variables). This way you can work on an example dataset that you’re personally interested in. If you can’t find something or have trouble loading it into R in time there are backup options in these packages:

    fivethirtyeight https://fivethirtyeight-r.netlify.app/
    palmerpenguins https://allisonhorst.github.io/palmerpenguins/
    modeldata https://modeldata.tidymodels.org/
    nycflights13 https://nycflights13.tidyverse.org/

Just be sure to identify in advance which variable you’ll use as an outcome to predict, and which variables you might use as predictors

#### Week 3 causality

Required reading

    Mixtape Sections 1.1, 1.2, and 3.1 up to 3.1.3 (stop before 3.1.4)
    MLstory Chapter 9 on Causality, roughly the first half (stop before the section called Experimentation, randomization, potential outcomes)

Supplemental reading

    Blog post on “double machine learning” up to the second histogram (note that material after that point is more advanced)
    MLstory Chapter 9 on Causality and Chapter 10 on Causal inference in practice

The first coursework questions are available at: https://ml4ds.com/weeks/04-classification/exercises/pset1.html

#### Week 4 classification

Required reading

    ISLR Chapter 4. This chapter is a bit lengthy, so it’s OK if you don’t carefully follow all the mathematics in sections 4.4 and 4.5 as long as you understand the concepts.
    MLstory Start Chapter 5 on optimization, read the first two sections on Optimization Basics and on Gradient Descent. You can stop when you reach Proposition 3.

Supplemental reading

    Wikipedia on Newton’s method and gradient descent (good for pictures and animations)
    CASI Chapter 4 for MLE theory, Chapter 8 sections 8.1-8.3 (more advanced material)

Coursework 1

You can find solutions for Coursework 1 here https://ml4ds.com/weeks/04-classification/exercises/pset1_answers.html

As a reminder, this coursework will not count toward final marks. You can compare your work to the example solutions, and if you still have any unresolved questions you can then submit your work on Moodle along with any specific feedback requests until the cut-off date.

####  Week 5 optimization

Required reading

    ISLR Chapter 6, Section 1 only.
    ISLR Chapter 7, Sections 1-3 and 6.
    MLstory Chapter 5 on optimization, read the section on Stochastic gradient descent and stop after the SGD quick start guide.

Supplemental reading

    MLstory Chapter 5 on optimization, the rest of the chapter (note that it contains some more advanced material).
    Wikipedia on Newton’s method and gradient descent (good for pictures and animations)


#### Week 6-7 reading week, validation

Required reading

    ISLR Finish reading Chapter 6 on linear models and regularisation (you can skim quickly through sections 6.3 and 6.5)
    ISLR Chapter 5 on resampling methods

Supplemental reading

    ESL Chapter 3, sections 1-6 and 10.
    CASI Chapters 7 and 16.

####  Week 8 high-dimensional regression

Hi, in this week's seminars and lectures we'll focus on high-dimensional regression. In the upcoming weeks we will cover non-linear methods in ISLR Chapters 7 and 8. This week is a good time to start reading ahead so that you'll have more time for the coursework which will be announced soon.
Required reading

    ISLR Chapter 7, particularly sections 7.7 and 7.8.3 on GAMs

#### Week 9 additive models

Required reading

    You should have already finished ISLR Chapter 7, especially sections 7.7 and 7.8.3 on GAMs
    Start ISLR Chapter 8, at least section 8.1 on basics of tree methods
    Start IML book Chapter 8, particularly Chapter 8.1 on PDPs, but skip Section 8.1.1 on feature importance

Next week we'll finish ISLR Chapter 8, and cover IML Chapter 8.3

#### Week 10 tree-based models

Required reading

    Finish ISLR Chapter 8
    IML book: Chapter 8.3 on feature interaction, but you can skip Section 8.3.2 on the theory

Supplemental reading

    Review the parts of ISLR Chapter 2 about k-nn, and also chapter/sections 3.5 and 4.7.6 (optionally, skim Chapter 12 section 4, especially 12.4.1, to remember the difference between k-nn and another method with a name that sounds somewhat similar--forgetting the difference between these can be a common cause of embarrassment in job interviews!)
    Read ISLR Chapter 9, especially section 9.3. We will be less interested in the details of SVMs and more focused on kernels as a generally useful concept/method.

#### Week 11 interpretation and causal redux

