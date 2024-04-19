configure_file( generateSRFigs.in.sh         generateSRFigs.sh           @ONLY)
configure_file( generateSRFigs_sup.in.sh     generateSRFigs_sup.sh       @ONLY)
configure_file( generateViolinPlot_sup.in.py generateViolinPlot_sup.py   @ONLY)
configure_file( generateCSV.in.sh            generateCSV.sh              @ONLY)
configure_file( generatePublicData.in.sh     generatePublicData.sh       @ONLY)
configure_file( generatePublicScalabilityAnalyzeData.in.sh
                generatePublicScalabilityAnalyzeData.sh
                @ONLY
              )

configure_file( generateSingleRunCSVs.in.sh  generateSingleRunCSVs.sh    @ONLY)

configure_file( evaluateAll.sh               evaluateAll.sh              @ONLY)

configure_file( iterateAllDataSets.in.sh     iterateAllDataSets.sh        @ONLY)
configure_file( compareLowerbound.in.py      compareLowerbound.py        @ONLY)
