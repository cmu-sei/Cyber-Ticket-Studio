# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


make_word = function(n_character){
    characters = sample(letters, n_character, replace = TRUE)
    return(paste0(characters, collapse = ''))
}

make_vocab = function(n){
    mean_word_length = 4
    word_lengths = 1+rpois(n, 4)
    return(sapply(word_lengths, dsim::make_word))
}

make_filename = function(n){
    root = make_word(n)
    extension = sample(c('docx', 'pdf', 'jpg', 'png', 'pdf', 'zip'), 1)
    return(paste(c(root, extension), collapse = '.'))
}

make_filenames = function(n){
    mean_filename_length = 6
    lengths = 1+rpois(n, 5)
    return(sapply(lengths, make_filename))
}

#' only of the form something.somewhere.tld
make_domain = function(){
    tld = sample(c('com', 'org', 'net', 'io', 'edu'), 1)
    something = make_word(1+rpois(1,3))
    somewhere = make_word(1+rpois(1,5))
    return(paste(c(something, somewhere, tld), collapse = '.'))
}

make_document = function(vocabs){
    # Decide how many of each vocab to include
    n = list(
        text = rpois(1, 200),
        ip   = rpois(1, 2),
        email = rpois(1, 2),
        filename = rpois(1, 2),
        domain = rpois(1, 1)
    )
    # Select random elements of each vocab
    kinds = c("text", "ip", "email", "filename", "domain")
    samples = sapply(kinds,
        function(k) sample(x = vocabs[[k]], size = n[[k]], replace = TRUE) )
    # Combine and randomly order the result
    words = as.character(unlist(samples))
    words = sample(words, length(words), replace = FALSE)
    return(paste(words, collapse = ' '))
}
