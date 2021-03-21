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
            corpus <- rainette::split_segments(
                corpus,
                segment_size=self$options$segsize
            )

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
            
            if (!self$options$doublecluster) {
                results <- rainette::rainette(
                    dtm,
                    k=self$options$kmeans,
                    min_uc_size=self$options$minucsize,
                    min_split_members=self$options$minsplit
                )
            } else {
                tryCatch({
                    results <- rainette::rainette2(
                        dtm,
                        uc_size1=self$options$minucsize,
                        uc_size2=self$options$minucsize2,
                        max_k=self$options$kmeans,
                        min_members=self$options$minsplit
                    )
                },
                error = function(e) {
                    warning('Double clustering returned the error: ',
                        geterrmessage())
                    results <- NULL
                })
            }

            plotData <- list(results, dtm)
            names(plotData) <- c('results', 'dtm')

            image <- self$results$plot
            image$setState(plotData)
        },
        .plot = function(image, ...) {
            if (length(self$options$text) == 0) {
                return()
            }

            plotData <- image$state

            if (is.null(plotData$results)) {
                stop('Analysis returned NULL results. ',
                    'Try to adjust the parameters or the corpus.')
            }

            tryCatch({
                if (!self$options$doublecluster) {
                    plot <- rainette::rainette_plot(
                        plotData$results,
                        plotData$dtm,
                        k=self$options$kgroup,
                        type=self$options$plottype,
                        n_terms=self$options$nterms,
                        free_scales=self$options$freescales,
                        measure=self$options$measure,
                        show_negative=self$options$negative,
                        text_size=self$options$textsize
                    )
                } else {
                    plot <- rainette::rainette2_plot(
                        plotData$results,
                        plotData$dtm,
                        k=self$options$kgroup,
                        criterion=self$options$partcriterion,
                        complete_groups=self$options$completegroups,
                        type=self$options$plottype,
                        n_terms=self$options$nterms,
                        free_scales=self$options$freescales,
                        measure=self$options$measure,
                        show_negative=self$options$negative,
                        text_size=self$options$textsize
                    )
                }
            },
            error = function(e) {
                stop('Plot returned the error: ', geterrmessage(),
                    '. Try to adjust the parameters.')
            })

            if (self$options$showstats) {
                private$.stats(plotData$results, plotData$dtm)
            }

            print(plot)
            TRUE
        },
        .stats = function(results, dtm) {
            if (!self$options$doublecluster) {
                groups <- rainette::cutree_rainette(results, k=self$options$kgroup)
            } else {
                groups <- rainette::cutree_rainette2(
                    results,
                    k=self$options$kgroup,
                    criterion=self$options$partcriterion
                )

                if (self$options$completegroups) {
                    groups <- rainette::rainette2_complete_groups(dtm, groups)
                }
            }

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
