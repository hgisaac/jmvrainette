# This file is a generated template, your changes will not be overwritten

hcaClass <- if (requireNamespace('jmvcore', quietly=TRUE)) R6::R6Class(
    "hcaClass",
    inherit = hcaBase,
    private = list(
        .run = function() {
            if (length(self$options$text) == 0) {
                return()
            }
            
            data <- self$data
            row.names(data) <- paste0('row', seq_len(nrow(data)))

            data[[self$options$text]] <- as.character(
                data[[self$options$text]]
            )

            corpus <- quanteda::corpus(data, text_field=self$options$text)
            corpus <- rainette::split_segments(corpus, segment_size=self$options$segsize)

            stpwd_lang <- paste0(self$options$lang, '_stopwords')
            stpwd_expression <- parse(text=paste0('jmvrainette::', stpwd_lang))

            dtm <- quanteda::dfm(
                corpus,
                remove=eval(stpwd_expression),
                tolower=self$options$tolower,
                remove_punct=self$options$rmvpunct
            )
            dtm <- quanteda::dfm_wordstem(dtm, language=self$options$lang)
            dtm <- quanteda::dfm_trim(dtm, min_termfreq=self$options$mintermfreq)
            
            tryCatch({
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
            error = function(e) {
                stop(paste(
                    'Analysis results the error:', geterrmessage(),
                    '. Try to adjust the parameters.'
                ))
            })
        },
        .plot = function(image, ...) {
            if (length(self$options$text) == 0) {
                return()
            }

            plotData <- image$state

            if (self$options$showstats) {
                private$.stats(plotData$result, plotData$dtm)
            }

            tryCatch({
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
            },
            error = function(e) {
                stop(paste(
                    'Plot results the error:', geterrmessage(),
                    '. Try to adjust the parameters.'
                ))
            })
        },
        .stats = function(results, dtm) {
            groups <- rainette::cutree_rainette(results, k=self$options$kgroup)
            stats <- rainette::rainette_stats(
                groups,
                dtm,
                measure=self$options$measure,
                n_terms=self$options$nterms,
                show_negative=self$options$negative
            )

            for (statsIndex in seq_len(length(stats))) {
                table <- jmvcore::Table$new(
                    self$options,
                    paste0('table', statsIndex),
                    paste('Cluster', statsIndex),
                    columns=list(
                        list(name='feature', title='Feature', type='text'),
                        list(name='chi2', title='Chi2', type='number'),
                        list(name='p', type='number', format='zto,pvalue'),
                        list(name='n_target', title='Number Target', type='integer'),
                        list(name='n_reference', title='Number Reference', type='integer'),
                        list(name='sign', title='Sign', type='text')
                    )
                )

                dataFrame <- stats[[statsIndex]]
                for (rowIndex in seq_len(nrow(dataFrame))) {
                    table$addRow(
                        rowIndex,
                        list(
                            feature=dataFrame[rowIndex, ]$feature,
                            chi2=dataFrame[rowIndex, ]$chi2,
                            p=dataFrame[rowIndex, ]$p,
                            n_target=dataFrame[rowIndex, ]$n_target,
                            n_reference=dataFrame[rowIndex, ]$n_reference,
                            sign=dataFrame[rowIndex, ]$sign
                        )
                    )
                }

                self$results$add(table)
            }
        }
    )
)
