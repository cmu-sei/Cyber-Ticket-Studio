# Cyber Ticket Studio

Cyber Ticket Studio (CTS) is a [Shiny app](https://shiny.rstudio.com/) that enables you to link cybersecurity incident tickets and view interactive visualizations of the incident data. CTS helps you identify previously unknown connections among reported cybersecurity incidents.


## Background
The Software Engineering Institute (SEI) developed CTS to support an exploratory analysis on a collection of DHS incident reports that contained over 400,000 unique indicators. CTS is an early prototype implementation of several analytics and is an ongoing research project.

Disclaimer: Since CTS is a pre-beta prototype project, we make no guarantees about its stability or functionality. In using CTS on your own data, you may encounter issues. If you experience problems, please file an issue on the repository’s homepage on github, and we will do our best to help you.

## How CTS Works
CTS calculates similarity metrics for cybersecurity incident reports and indicators, and attempts to link them into communities that are likely to be related. You can then view and interact with the resulting data in a web browser.

To apply CTS to new data sources of cyber incidents ticket, you must first format the tickets as rows in a special comma-separated values (CSV) file, as described in the Getting Started section below.

Details about how to use CTS are available in the CTS Method Overview section of this document.


## Overview of the process for using CTS
CTS is an application that runs on Rstudio's shiny. This section describes the steps you need to run CTS on your own cyber incident data to find patterns. Each step below has section below with detailed instructions on how to perform the step and what dependencies or commands are required.

### 1 - Install CTS and its dependencies
To use CTS, you will first need to install R, Rstudio, and Shiny to use CTS. You will also need python installed and Cyobstract if you want to do indicator extraction (usually a preliminary step to using CTS).

### 2 - Data
CTS requires a datafile of cybersecurity indicators. To prepare demonstration data, simply run
    ```
    Rscript data/make_example_data.R
    bash backend/build_backend.sh
    ```    
To use your own data, follow the detailed steps see the [Your Data](#your_data) section below.


### 3 - Launch CTS on your Data
Open an Rstudio session. You can do this on your desktop or remotely using Rstudio Server. [See the Rstudio website for more information](https://shiny.rstudio.com/articles/running.html.)

Finally, run Rstudio and launch the CTS app by running

    ```
    library(shiny)
    library(rsrc)
    USER = rsrc::load_user()
    shiny::runApp(file.path(USER$repository_pth, 'dashboard'))
    ```

## Part 1 - Install CTS and its dependencies
CTS has been successfully run only on a limited selection of linux-based operating systems. Several of the installation steps below depend on OS-specific installation instructions noted in `docs/[OS].md`

1. Create a configuration file by following the instructions in `config_example`.

2. Install R

3. Install [Rstudio](https://www.rstudio.com/) (or Rstudio Server if operating CTS on a remote host)

4. Install Python 2.7 including the following dependencies. (You can also trying using python 3.6 but we have not tested it yet.)

    `cyobstract`: See https://github.com/cmu-sei/cyobstract

    `pysrc`: Run `python setup.py install` inside of `/src/pysrc`

    ```bash
    conda install munch
    pip install progress
    ```
    We used the Anaconda distribution of python and recommend you do as well.  We tried to include all dependencies here, but the code may rely on packages that are included with the standard Anaconda Python distribution, only some of which are documented above.

5.	Identify and install R-package dependencies. If you are on a remote host, install these dependencies at the terminal inside of a sudo R session; this will make the packages globally available. If you do not use sudo, you should be able to serve the CTS app to yourself.

    ```R
    dependencies = c(
        'data.table',
        'devtools',
        'DT',
        'generator',
        'igraph',
        'rjson',
        'RSQLite',
        'yaml')
    pkg_list = row.names(installed.packages())
    setdiff( dependencies, pkg_list)
    # Installing packages in Rstudio individually:  install.packages([missing package])
    # For installing from a command line R session:
    for(dep in dependencies){
        if(dep %in% pkg_list) next
        install.packages(dep,
                         repos = "https://cran.rstudio.com/",
                         dependencies = TRUE)
    }
    ```

6. Install these packages from github:

    ```R
    library(devtools)
    install_github('ramnathv/rCharts')
    ```
Install the internal R packages:

    ```R
    library(yaml)
    if(!file.exists('~/.cyber_ticket_studio')){
        stop("You need set up your `~/.cyber_ticket_studio` file -- see `example_config`")
    }
    USER = yaml::read_yaml('~/.cyber_ticket_studio')
    fp = function(s) file.path(USER$repository_pth, s)
    install.packages(fp('src/rsrc'), repos = NULL, type="source")
    install.packages(fp('src/dsim'), repos = NULL, type="source")
    install.packages(fp('src/ShinyViews'), repos = NULL, type="source")
    ```

## Part 2 - Prepare your Incident Data

If you are an incident response team, you may have a system for tracking your incidents. Alternatively, you may track conversations in email systems or store reports in flat files.

CTS expects to ingest a CSV file to populate a database of incident reports and their indicators before it can perform visualization and pattern matching. You may need to manipulate your datafiles into a CSV file before you can load your data into CTS.

Here are the steps for creating and using the datafile that CTS requires:

1. **Make a datafile that is readable by CTS**

To enable CTS to read your data, create a CSV file called "tickets.csv" and ensure that there is a row for each cyber incident or ticket. The file must have exactly the following fields:

    - ticket_id (positive integer)
    - ticket_timestamp (unix time - a positive integer)
    - ticket_text (string)
    - ticket_category (string)
    - ticket_organization (string)

To learn more about required time formats, see the Wikipedia page on [unix time](https://en.wikipedia.org/wiki/Unix_time).

Depending on your incident tracking system, you may need to first concatenate numerous bits of free text or comments associated with the ticket to generate the `ticket_text` string.

2. **Make the datafile visible to CTS**

To make your data visible to CTS, save “tickets.csv” inside the directory specified by the `datdir` variable. You specify this variable in the `~/.cyber_ticket_studio` file.

3. **Build the backend**

In the `backend` directory, run `bash build_backend.sh`.

**Debugging:**

If the CTS app fails on your data, ensure that CTS works on the example data set provided. If the app continues to fail, file a ticket on the CTS repository homepage.

## Part 3 - Launch CTS on your Data
Open an Rstudio session. You can do this on your desktop or remotely using Rstudio Server. [See the Rstudio website for more information](https://shiny.rstudio.com/articles/running.html.)

Finally, run Rstudio and launch the CTS app by running

    ```
    library(shiny)
    library(rsrc)
    USER = rsrc::load_user()
    shiny::runApp(file.path(USER$repository_pth, 'dashboard'))
    ```

# CTS Analysis Methods

The CTS analysis pipeline begins when you point CTS at a dataset of incident reports (or tickets) for it to load.

CTS then runs `backend/build_backend.sh` which uses Cyobstract to extract observables from the `ticket_text` field in the datafile. Observables are strings, including the IP address, domain name, and other potential markers of cyber activity reported in an incident report. Observables that have been associated with malicious activity are typically referred to as *indicators*. However, CTS does not distinguish between malicious and benign observables. Some observables in an incident report may be benign, but they can still useful as markers of commonality among tickets. These can also be used for searching and filtering by cyber data analysts.

## Computing Similarity
CTS also performs numerous data pre-processing steps related to computing similarities among observables and incident reports. By default, CTS computes the similarity between two tickets as the [Jaccard](https://en.wikipedia.org/wiki/Jaccard_index) similarity, based on the sets of distinct observables contained in each of the ticket. Conversely, CTS computes the similarity between two observables as the Jaccard similarity, based on the sets of tickets that contain the observable.

Conceptually, CTS represents incident tickets (or observables) with a graph where each unique incident (or observable) is a [vertex](https://en.wikipedia.org/wiki/Vertex_(graph_theory), also called a node. Edges connect the incident tickets (or observables). Jaccard similarities represent the strengths of the connections between incidents (or observables).

Read more about our insights and our choice of the Jaccard similarity in the article titled [Data Mining for Efficient Collaborative Information Discovery](https://dl.acm.org/citation.cfm?id=2808130)

## Community Detection
After computing similar for all observables and for all tickets CTS builds a list of communities of incidents (or observables) by applying the [Fast-Greedy community detection algorithm](http://www.arxiv.org/abs/cond-mat/0408187) to the similarity graph. This algorithm is a hierarchical clustering method and can reveal connections that are not obvious. For instance, if A is similar to B, and B is similar to C, the cluster ABC could form, even if A bears very little resemblance to C.

## Analyst interaction with CTS results
CTS presents the results of the clustering algorithm on its `Communities` tab. CTS also contains an interactive similarity dashboard, where you can easily tune your own similarity metric based on your opinion of what information in the incident reports is related to your investigation.

Sometimes you might want to restrict an investigation to consider only a single organization. In that case, you should include the `ticket_organization` in the similarity. Putting a high-enough "weight" on `ticket_organization` ensures that field is heavily favored when incidents are returned on a query. In that case, only incidents from the same organization will be considered most 'similar' regardless of the observables in the tickets.

Read more about the similarity algorithms in CTS in our [2017 FIRST Conference Presentation: Measuring Similarity Between Cyber Security Incident Reports.](https://www.first.org/resources/papers/conf2017/Measuring-Similarity-Between-Cyber-Security-Incident-Reports.pdf).


## Resources

- [Woods, Bronwyn & Perl, Sam. Discovering patterns of activity in unstructured incident reports at scale. FIRST Conference Presentation. June 2015.](https://www.first.org/resources/papers/conf2015/first_2015_-_perl-_woods-_millar_-_discovering_patterns_of_activity__20150603.pdf)

- [Woods, Bronwyn; Perl, Sam; & Lindauer, Brian. Data Mining for Efficient Collaborative Information Discovery. The 2nd ACM Workshop on Information Sharing and Collaborative Security (WISCS): WISCS2015. October 2015.](https://dl.acm.org/citation.cfm?id=2808130)

- [Kurtz, Zach; Perl, Sam. Measuring Similarity Between Cyber Security Incident Reports. FIRST Conference Presentation June 2017.](https://www.first.org/conference/2017/program#pmeasuring-similarity-between-cyber-security-incident-reports)

## References

- [Clauset, Aaron; Newman, Mark E.J.; and Moore, Cristopher. Finding community structure in very large networks. Physical Review. E 70.6 066111. 204. August 2004.](http://www.arxiv.org/abs/cond-mat/0408187)

## Contact

To learn more about CTS, see the resources above or contact us using the email addresses below. We’re happy to hear feedback or answer questions. We’re particularly interested to hear about your experiences as you’ve applied CTS to new data sets!

Sam Perl: sjperl at cert dot org
Zachary Kurtz: ztkurtz at cert dot org
Robin Ruefle: rmr at cert dot org
