# This file is a generated template, your changes will not be overwritten

hcaClass <- if (requireNamespace('jmvcore', quietly=TRUE)) R6::R6Class(
    "hcaClass",
    inherit = hcaBase,
    private = list(
        .run = function() {
            data <- self$data
            row.names(data) <- paste0('row', 1:nrow(data))

            data[[self$options$text]] <- as.character(
                data[[self$options$text]]
            )

            corpus <- quanteda::corpus(data, text_field=self$options$text)
            corpus <- rainette::split_segments(corpus, segment_size=self$options$segsize)

            stpwd_lang <- paste0(self$options$stopwords, '_stopwords')
            stpwd_expression <- parse(text=paste0('jmvrainette::', stpwd_lang))

            dtm <- quanteda::dfm(
                corpus,
                remove=eval(stpwd_expression), # TODO: stopwords::stopwords(self$options$stopwords),
                tolower=self$options$tolower,
                remove_punct=self$options$rmvpunct
            )
            dtm <- quanteda::dfm_wordstem(dtm, language=self$options$lang)
            dtm <- quanteda::dfm_trim(dtm, min_termfreq=self$options$mintermfreq)
            
            results <- rainette::rainette(
                dtm,
                k=self$options$kmeans,
                min_uc_size=self$options$minucsize,
                min_split_members=self$options$minsplit
            )

            plotData <- list(results, dtm)
            names(plotData) <- c('result', 'dtm')

            image <- self$results$plot
            image$setState(plotData)
        },
        .plot = function(image, ...) {
            plotData <- image$state

            plot <- rainette::rainette_plot(
                plotData$result,
                plotData$dtm,
                k=self$options$kgroup,
                type=self$options$plottype,
                n_terms=self$options$nterms,
                free_scales=self$options$freescales,
                measure=self$options$measure,
                show_negative=self$options$negative,
                text_size=self$options$textsize
            )

            print(plot)
            TRUE
        }
    )
)
