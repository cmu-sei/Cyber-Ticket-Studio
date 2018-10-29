# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345



# explain_related_tickets2 = "For instance, if you don't care about the Jaccard similarity (which 
#     rates two tickets as similar based on the size of the overlap between the sets of observables
#     they contain), just move the corresponding slider to 0.  Alternatively, if you want to weight
#     the Jaccard similarity in proportion to the sizes of the sets involved, check the 'Weight JaccardSim' box.
#     For a broad discussion of computing similarity between tickets, see "

inv_det_related_subview = tabPanel(
    "Related tickets",
    h4('Similarity between tickets'),
    p(
        "Related tickets are tickets that are similar to a given ticket. 
        However, there is no standard
        all-purpose approach to measuring similarity between tickets. The sliders below allow you to
        specify what kinds of things you care about when you are 
        searching for related tickets. For a broad discussion of computing similarity between tickets, see ", 
        a("measuring similarity between cyber security incident reports",
            href="https://www.first.org/resources/papers/conf2017/Measuring-Similarity-Between-Cyber-Security-Incident-Reports.pdf",
            target="_blank")
        ),
    h5('Definitions'),
    #p('Here are brief definitions. See the docs for details'),
    helpText(HTML("<div style=\"text-indent: 25px\">
        JaccardSim = the Jaccard similarity with the ticket of interest (specified above) and in terms of the sets
            of observables found in each ticket.          
        </div>")),
    helpText(HTML("<div style=\"text-indent: 25px\">
        GlobalSim = a linear combination of the JaccardSim, category, organization, and time similarities,
        using the coefficients specified by the sliders. Note that the coefficient of JaccardSim depends 
        also on whether you select the 'Weight JaccardSim by count?' option, which puts greater weight on
        JaccardSim when the numbers of observables involved in the similarity computation are large.
        </div>")),
    fluidRow(
        column(4,
            sliderInput("sim_jaccard_coeff", "Jaccard coefficient:", 
                       min=0, max=1, value=1, step = 0.01)
        ),
        column(4,
            checkboxInput("sim_use_jaccard_counts", "Weight JaccardSim by count?", value=FALSE)
        ),        
        column(4,
            sliderInput("sim_time_coeff", "Time coefficient:", 
                       min=0, max=1, value=0, step = 0.01)
        )
    ),
    fluidRow(
        column(4,
            sliderInput("sim_category_coeff", "Category coefficient:", 
                       min=0, max=1, value=0, sep = 0.01)
        ),
        column(4,
               sliderInput("sim_organization_coeff", "Organization coefficient:", 
                           min=0, max=1, value=0, step = 0.01)
        )
    ),
    dataTableOutput("INV_RELATED_table")
)
