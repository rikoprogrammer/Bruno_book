# Practice Lessons from Bruno Book - Building Reproducible Analytical Pipelines in R
![](images/bcover.png)

## Housing data for Luxembourg

These scripts for the R programming language download nominalhousing prices from the *Observatoire de l'Habitat* and tidy them up into a flat data frame.

Currently there is only script ```script_01.R``` that does both data cleaning and analysis of the data.

## Key lessons

This book is for anyone working with data who want to make their work as reproducible as possible. The main goal is to teach you how to use some of the best practices from software engineering and DevOps to make your projects robust, reliable and reproducible. It is divided into two main parts. The dominant theme for part one is 'Don't Repeat Yourself' - DRY while the theme for part two is 'Write It down'.

### PART 1 - DRY

For our work in data science to be truly reproducible we need to master three things; **version control** with Git, **Functional** Programming and **Literate** programming.

**Version Control with Git**

![](images/conflicts.png)

                       Key takeaways

We need to learn how to version our work using Git. Git is the software used for version control while GitHub is a hosting platform, we have other platforms like GitLab etc, but GitHub is the most common among developers/scientists. With practice anyone can learn Git, its not that much complicated and it offers immense benefits in the long run. You can install Git here: https://git-scm.com/downloads and sign up for a free GitHub account here: https://github.com/. This book will teach you all the basics you need to get started but we have other resources which into much details; eg https://guides.github.com/activities/hello-world/.