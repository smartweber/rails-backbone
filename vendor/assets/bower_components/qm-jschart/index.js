$QM = jQuery.noConflict( true );
$QM(function () {
  colorlist = ['#FF0000','#FF00FF','#00FF00','#FF6600'];
  colorlist.unshift(qmChartOptions.params.initSymbolColor);

    var CIhtml = '';

    for (var i = 0; i < qmChartOptions.params.compareIndices.length; i++) {
        var obj = qmChartOptions.params.compareIndices[i];
        var name = decodeURIComponent(qmChartOptions.params.compareIndicesNames[i]);
        CIhtml += '<label for="'+obj+'"><input class="checkbutton" type="checkbox" value="'+obj+'"> '+name+'</label>';
    }
    $QM("#qm_compareInd").append(CIhtml);


    if (qmChartOptions.params.granlist[0] != '') {
        if (qmChartOptions.params.granlist[0] == 'on') {
            qmChartOptions.params.granlist = '1,2,3,5,10,15,30,60'.split(',');
        }

        var GLhtml = '';
        for (var i = 0; i < qmChartOptions.params.granlist.length; i++) {
            var o = qmChartOptions.params.granlist[i];
            GLhtml += '<li><a id="' + o + '" href="#">' + o + 'm</a></li>';
        }
        $QM('#qm_dd_4').show();
        $QM(".qm_int").append(GLhtml);
    }

  compare = false;

  if (qmChartOptions.params.chscale == 0 || qmChartOptions.params.chscale == 1) {
      qmChartOptions.params.dateDT = 'intra';
  }
  else {
      qmChartOptions.params.dateDT = 'eod';
  }

    if (qmChartOptions.params.chtype == 'line' || qmChartOptions.params.chtype == 'area') {
      qmChartOptions.params.time = 'line';
  }
  else {
      qmChartOptions.params.time = 'ohlc';
  }


    function toggleFlags (a,b) {
        for (var i = 0; i < qmChartOptions.chartRef.series.length; i++) {
            if (qmChartOptions.chartRef.series[i].type == 'flags') {
                if (a==qmChartOptions.chartRef.series[i].options.flagType) {
                    if (b==true) {
                        qmChartOptions.chartRef.series[i].show();
                    }
                    else {
                        qmChartOptions.chartRef.series[i].hide();
                    }
                }
            }
        };
    }

  function bindButtons (z) {

    $QM('.qm_dropdown').hover(function() {
      if ($QM(this).hasClass('qm_disabled')) { return; }
        var timer = $QM(this).data('timer');
        if(timer) clearTimeout(timer);
        $QM(this).children('.qm_dropdown-menu').show();
    }, function() {
        var t = this;
        $QM(t).data('timer', setTimeout(function(){ $QM(t).children('.qm_dropdown-menu').hide(); }, 250));
    });

    $QM('.qm_ind .checkbutton').on('click', function(event) {
      if (this.checked) {
        toggleFlags(this.value,true);
      }
      else {
        toggleFlags(this.value,false);
      }
    });

    $QM('.qm_chartype_dropdown a').click(function(event) {
      $QM('.qm_chartype_dropdown li.active').removeClass('active');
      $QM(this).parent().addClass('active');

      qmChartOptions.chartRef.showLoading();

      switchDataSet(null, this.id);

      setTimeout(function() {
        qmChartOptions.chartRef.redraw();
        qmChartOptions.chartRef.hideLoading();
      }, 350);

    });
      $QM('.qm_int a').click(function(event) {
          $QM('.qm_int li.active').removeClass('active');
          $QM(this).parent().addClass('active');

          qmChartOptions.params.granularity = this.id;

          ldSymbolData(qmChartOptions.params.symbol,qmChartOptions.params.initSymbolColor,true);

      });

    $QM('.qm_compare .checkbutton').on('click', function(event) {
      $QM(this).toggleClass('checked');
      if ($QM(this).hasClass('checked')) {
        ldSymbolData(this.value);
      }
      else {
        removeSymbolData(this.value);
      }
      $QM('.qm_compare').removeAttr("style");
    });

    $QM.ui.autocomplete.prototype._renderItem = function( ul, item ) {
      return $QM( "<li>" )
      .data( 'item.autocomplete', item )
      .append( "<a>" + item.symbol + "<br>" + item.name + "</a>" )
      .appendTo( ul );
    }

    $QM( ".qm_mainlookup, .qm_compareinput" ).autocomplete({
      source: function( request, response ) {
      $QM.ajax({
        url: 'http://app.quotemedia.com/lookup?q='+request.term+'&limit=10&timestamp=1404243009292&async=true&webmasterId='+qmChartOptions.params.wmid+'&callback=?',
        dataType: "jsonp",
        success: function( data ) {
          response( data );
        }
      });
     },
    minLength: 1,
    focus: function( event, ui ) {
      $QM( this ).val( ui.item.symbol.toUpperCase() );
        var timer = $QM(this).parents('.qm_dropdown').data('timer');
        if(timer) clearTimeout(timer);
    },
    select: function( event, ui ) {
      $QM( this ).val( ui.item.symbol.toUpperCase() );
      var izInit = ($QM(this).parents('.qm_dropdown').length) ? false : true;
      // console.log(izInit);
      if (event.keyCode==13) {
        ldSymbolData(ui.item.symbol.toUpperCase(),false,izInit);
      }
      else {
        ldSymbolData(ui.item.symbol.toUpperCase(),false,izInit);
      }
    },
    open: function() {
      $QM( this ).removeClass( "ui-corner-all" ).addClass( "ui-corner-top" );

    },
    close: function() {
      $QM( this ).removeClass( "ui-corner-top" ).addClass( "ui-corner-all" );
    }
    });

    $QM(".qm_mainlookup").keypress(function(e) {
      if(e.keyCode == 13) {
        e.preventDefault();
        ldSymbolData(this.value.toUpperCase(),qmChartOptions.params.initSymbolColor,true);
        $QM(this).autocomplete('close');
      }
    });

    $QM('.qm_lookup_buttom').click(function(event) {
      event.preventDefault();
      var $inP = $QM(this).siblings('input');
      if ( $inP.hasClass('qm_mainlookup') ) {
        ldSymbolData($inP.val().toUpperCase(),qmChartOptions.params.initSymbolColor,true);
      }
      else {
        ldSymbolData($inP.val().toUpperCase());
      }
    });
    $QM(".qm_compareinput").keypress(function(e) {
      if(e.keyCode == 13) {
        e.preventDefault();
        ldSymbolData(this.value);
        $QM(this).autocomplete('close');
        $QM('.qm_compare').removeAttr("style");
      }
    });

  }

  function removeSymbolData (sym) {
    qmChartOptions.chartRef.showLoading();

    for (var i = qmChartOptions.chartRef.series.length - 1; i >= 0; i--) {
      if (qmChartOptions.chartRef.series[i].options.symbol == sym){
          $QM("input[type=checkbox][value='"+sym+"']").prop("checked",false);
            qmChartOptions.chartRef.series[i].remove();
            delete chartDataSetsObj[sym];
      }
    };
    if (Object.keys(chartDataSetsObj).length==1) {
      $QM('#qm_dd_2').removeClass('disabled');
      compare = false;
      qmChartOptions.chartRef.yAxis[0].setCompare('none');
    }
    qmChartOptions.chartRef.hideLoading();
  }

  function removeAllSymbolData () {
    var seriesLength = qmChartOptions.chartRef.series.length;
      for (var i = seriesLength - 1; i >= 0; i--) {
        if (qmChartOptions.chartRef.series[i].type=='areaspline'){
          continue;
        }
        qmChartOptions.chartRef.series[i].remove();
      };
            compare = false;
      qmChartOptions.chartRef.yAxis[0].setCompare('none');

  }

function switchDataSet(type, xchtype) {

    var zType = (!type) ? qmChartOptions.params.dateDT : type;
    var zchType = (!xchtype) ? false : xchtype;

    for (var i = 0; i < qmChartOptions.chartRef.series.length; i++) {
        var serie = qmChartOptions.chartRef.series[i];
        if (serie.type == 'flags') continue;
        if (serie.type == 'column') { // Volume Chart
          if (chartDataSetsObj[serie.options.symbol][zType].line.length!=0) {
            var mx = chartDataSetsObj[serie.options.symbol][zType].volume.length -1;
              serie.update({
                  data: chartDataSetsObj[serie.options.symbol][zType].volume,
                  max: chartDataSetsObj[serie.options.symbol][zType].volume[mx][0],
                  dataGrouping: {
                      enabled: false
                  }
              }, true);
          }
        } else if (serie.type == 'areaspline') {
          if (chartDataSetsObj[serie.options.symbol][zType].line.length!=0) {
              if (Object.keys(chartDataSetsObj).length == 1) { //Navigator pane only update on first data set
                var mx = chartDataSetsObj[serie.options.symbol][zType].volume.length -1;
                  serie.update({
                      data: chartDataSetsObj[serie.options.symbol][zType].line,
                      max: chartDataSetsObj[serie.options.symbol][zType].line[mx][0],
                      min: chartDataSetsObj[serie.options.symbol][zType].line[0][0]

                  }, true);
                  qmChartOptions.chartRef.xAxis[1].options.ordinal = true;
                  qmChartOptions.chartRef.xAxis[1].setExtremes();
              }
            }
        } else if (serie.type != xchtype) { //Main Chart

            if (xchtype == 'line' || xchtype == 'area') {
                cType = 'line';
            } else {
                cType = 'ohlc';
            }
           if (chartDataSetsObj[serie.options.symbol][zType][cType].length!=0) {
            var mx = chartDataSetsObj[serie.options.symbol][zType][cType].length -1;
              serie.update({
                  type: xchtype,
                  data: chartDataSetsObj[serie.options.symbol][zType][cType],
                  max: chartDataSetsObj[serie.options.symbol][zType][cType][mx][0],
                  dataGrouping: {
                      enabled: false
                  }
              }, true);

            if (xchtype == 'area') {
                qmChartOptions.chartRef.yAxis[0].update({
                    type: 'logarithmic'
                });
            } else {
                qmChartOptions.chartRef.yAxis[0].update({
                    // type: 'datetime',
                    // tickAmount: 8
                });
            }
            if (Object.keys(chartDataSetsObj).length == 1) {
                qmChartOptions.chartRef.yAxis[0].setCompare('none');
            }
                        }

        }
    };
}

function ldSymbolData ( symbol, colorOveride, isInit ) {
  var v_symbol = (!symbol) ? alert('Please input a symbol') : symbol.toUpperCase();
  var v_isInit = (!isInit) ? false : isInit;
  if (v_isInit) {
      removeAllSymbolData();
      chartDataSetsObj = {};
  }
    else {
      qmChartOptions.params.chtype = 'line';
  }
  var v_colorOveride = (!colorOveride) ? colorlist[ parseInt(Object.keys(chartDataSetsObj).length) ] : colorOveride;

  if (Object.keys(chartDataSetsObj).length == 5) {
    alert('Maximum of 5 compare symbols');
    return;
  }


  qmChartOptions.chartRef.showLoading();

  var jURL = qmChartOptions.params.qmhost+'/getChartData.go?symbol='+v_symbol+'&webmasterId='+qmChartOptions.params.wmid+'&start='+qmChartOptions.params.startDate+'&granularity='+qmChartOptions.params.granularity+'&callback=?';

  $QM.getJSON(jURL)
    .done(function( data ) {
      if (!data) {
        $QM('#qm_invalid_data').text('Invalid Symbol: ' + v_symbol).show();
        $QM('.qm_chart_cont > div').css('visibility', 'visible');

        $QM('.qm_taglist').hide();
        $QM('.qm-ajax-loader').hide();
        $QM('#qm_container').hide();
        return;
      }
      else {
        $QM('#qm_container').show();
        $QM('.qm_taglist').show();
        $QM('.qm_chart_cont > div').css('visibility', 'visible');
        $QM('.qm-ajax-loader').hide();
        $QM('#qm_invalid_data').hide();
      }

      // data[0].pop();

      // console.log(data);

      var dataSetObj = {
        'symbol' : v_symbol,
        'eod' : {
          'ohlc' : [],
          'line' : [],
          'volume' : []
        },
        'intra' : {
          'ohlc' : [],
          'line' : [],
          'volume' : []
        },
        'ind' : {
            'splits' : data[2],
            'dividends' : data[3],
            'earnings' : data[4]
        }
      }
      for( var i = 0; i < data[0].length; i++ ) {
        dataSetObj.eod.ohlc.push([
          data[0][i][0], //date
          (data[0][i][1]) ? data[0][i][1] : data[0][i][4], //o
          (data[0][i][2]) ? data[0][i][2] : data[0][i][4], //h
          (data[0][i][2]) ? data[0][i][3] : data[0][i][4], //l
          data[0][i][4]  //close
        ]);

        dataSetObj.eod.line.push([
          data[0][i][0], //date
          data[0][i][4]  //close
        ]);
        dataSetObj.eod.volume.push([
          data[0][i][0], //date
          data[0][i][5] //vol
        ]);
      };
      if (data[1].length) {
        for( var i = 0; i < data[1].length; i++ ) {
          dataSetObj.intra.ohlc.push([
            data[1][i][0], //date
            data[1][i][1], //o
            data[1][i][2], //h
            data[1][i][3], //l
            data[1][i][4]  //close
          ]);
          dataSetObj.intra.line.push([
            data[1][i][0], //date
            data[1][i][4]  //close
          ]);
          dataSetObj.intra.volume.push([
            data[1][i][0], //date
            data[1][i][5] //vol
          ]);
        };
      }
      else {
        dataSetObj.intra.ohlc = dataSetObj.eod.ohlc;
        dataSetObj.intra.line = dataSetObj.eod.line;
        dataSetObj.intra.volume = dataSetObj.eod.volume;
      }

      chartDataSetsObj[v_symbol] = dataSetObj;
      qmChartOptions.chartData[v_symbol] = chartDataSetsObj;

      var eodGroup = [
            ['minute', [5]],
            ['hour',   [.1,.5,24]],
            ['day',    [1]],
            ['week',   [1]],
            ['month',  [1]],
            ['year',   [.1]]
      ];

        if (data[2].length) {
          for (var i = 0; i < data[2].length; i++) {
            //data[2][i] = data[2][i][0];
            data[2][i] = { x: data[2][i][0], text: data[2][i][1] };
          };
        }
        if (data[3].length) {
          for (var i = 0; i < data[3].length; i++) {
            data[3][i] = { x: data[3][i][0], text: data[3][i][1] };
          };
        }
        if (data[4].length) {
          for (var i = 0; i < data[4].length; i++) {
            data[4][i] = { x: data[4][i][0], text: [data[4][i][1],data[4][i][2]] };
          };
        }

        var newSymbolSeries =
            [{
                type   : qmChartOptions.params.chtype,
                name   : v_symbol,
                symbol : v_symbol,
                id     :'main'+v_symbol,
                data   : dataSetObj[qmChartOptions.params.dateDT][qmChartOptions.params.time],
                color  : v_colorOveride,
                dataGrouping: {
                    units: eodGroup,
                    forced: false,
                    enabled: false
                }
            }, {
                type         : 'column',
                showInLegend : false,
                symbol       : v_symbol,
                name         : 'Volume',
                id           : 'vol'+v_symbol,
                data         : dataSetObj[qmChartOptions.params.dateDT].volume,
                color        : v_colorOveride,
                yAxis        : 1,
                dataGrouping : {
                  units        : eodGroup,
                  enabled: false
                }
            },{
                yAxis: 0,
                title        : 'S',
                type         : 'flags',
                visible      : false,
                id           : 'eodsplits'+v_symbol,
                name         : "Splits "+v_symbol,
                flagType     : "splits",
                color        : 'orange',
                symbol : v_symbol,
                showInLegend : false,
                data         : data[2],
                width        : 10,
                onSeries     : 'main'+v_symbol
            }, {
              yAxis: 0,
              title        : 'D',
              type         : 'flags',
              id           : 'eoddividends'+v_symbol,
              name         : 'Dividends '+v_symbol,
              flagType     : "dividends",
              showInLegend : false,
              data         : data[3],
              color        : 'blue',
              symbol : v_symbol,
              width        : 10,
              visible      : false,
              onSeries     : 'main'+v_symbol
          }, {
            title        : 'E',
            yAxis        : 0,
            type         : 'flags',
            id           : 'eodearnings'+v_symbol,
            visible      : false,
            name         : "Earnings "+v_symbol,
            flagType     : "earnings",
            color        : 'green',
            showInLegend : false,
            symbol : v_symbol,
            data         : data[4],
            width        : 10,
            onSeries     : 'main'+v_symbol
          }];



        if (v_isInit) {
          $QM('.qm_taglist').html('');
          $QM('#qm_dd_2').removeClass('disabled');
          $QM('.checkbutton').removeClass('checked');
          removeAllSymbolData();

        }

        qmChartOptions.chartRef.addSeries(newSymbolSeries[0]);
        qmChartOptions.chartRef.addSeries(newSymbolSeries[1]);



        if (data[2].length) { qmChartOptions.chartRef.addSeries(newSymbolSeries[2]); }
        if (data[3].length) { qmChartOptions.chartRef.addSeries(newSymbolSeries[3]); }
        if (data[4].length) { qmChartOptions.chartRef.addSeries(newSymbolSeries[4]); }

        if (v_isInit) {
          var nav = qmChartOptions.chartRef.get('navigator');


          nav.setData(dataSetObj.eod.line);
          nav.userOptions.symbol = v_symbol;
          nav.options.symbol = v_symbol;
          // debugger;
          // nav.options.symbol = v_symbol;
          $QM('.qm_chart_cont > div').css('visibility', 'visible');
          $QM('.qm-ajax-loader').hide();
          $QM('<div class="tag" data-color='+v_colorOveride+' style="border:1px solid '+v_colorOveride+'"><span class="'+v_symbol+'">'+v_symbol+'</span>').appendTo('.qm_taglist');
          $QM('.tag').hover(function() {
              $QM(this).css('background-color', $QM(this).attr('data-color'));
            }, function() {
              $QM(this).css('background-color', 'transparent');
          });

            $QM('.qm_ind .checkbutton:checked').each(function(){
                toggleFlags(this.value,true);
            });
        }
        else {
          $QM('<div class="tag" data-color='+v_colorOveride+' style="border:1px solid '+v_colorOveride+'"><span class="'+v_symbol+'">'+v_symbol+'</span><a class="remove"> x</a>').appendTo('.qm_taglist');
          $QM('.remove').on('click', function(event) {
            event.preventDefault();
            removeSymbolData($QM(this).siblings()[0].classList[0]);
            $QM(this).parents('.tag').remove();
          });
            switchDataSet(null, 'line');
            compare = true;
            $QM('#qm_dd_2').addClass('disabled');
            qmChartOptions.chartRef.yAxis[0].update({ type: 'linear'});
            qmChartOptions.chartRef.yAxis[0].setCompare('percent');
        }
        setTimeout(function() {
              qmChartOptions.chartRef.redraw();
              qmChartOptions.chartRef.hideLoading();
            }, 350);
    })
    .fail(function( jqxhr, textStatus, error ) {
      var err = textStatus + ", " + error;
      console.log( "Request Failed: " + err );

    });
}

  $QM(".qm_ind > *,.qm_compare > *").click(function(e) {
    e.stopPropagation();
  });

  if (qmChartOptions.params.hideVolumePane==true) {
    var yAxisHeight = '100';
    var yAxisHeight2 = '-100';
  }
  else {
    var yAxisHeight = '80';
    var yAxisHeight2 = '85';
  }

  var hasSwitchDataType = false;
  var cMin = 0;
  var cMax = 0;

    jsChart = $QM('#qm_container').highcharts('StockChart', {
      credits: {
        text: 'quotemedia.com',
        href: 'http://www.quotemedia.com',
        style: {
          cursor: 'pointer',
          color: qmChartOptions.params.xyzColor
        }
      },
      chart: {
        events: {
          load: function(chart) {
            bindButtons(chart);
          }
        },
        reflow: true,
        zoomType: 'x',
        marginTop: 2
      },
      plotOptions: {
        series: {
          compare: function() {
            return (compare) ? 'percent' : 'value'
          },
          lineWidth: 1,
          events: {
            legendItemClick: function () {
              return false; // <== returning false will cancel the default action
          }
        }
      }
      },
      navigator: {
        adaptToUpdatedData: true,
        series: {
          color: colorlist[0],
          lineColor: colorlist[0],
          id: 'navigator'
        },
        enabled : qmChartOptions.params.hideNavigtor
      },
      legend: {
        enabled : false,
        align : 'left',
        borderWidth : 0,
        verticalAlign : 'top',
        y : -18,
        x: -5,
        shadow : false,
        floating : true ,
        useHTML: false,
        itemWidth: 100
      },
      exporting: { enabled: false },
      rangeSelector: {
        buttonTheme: {
          states: {
            select: {
              fill: qmChartOptions.params.rangeColor,
              style: {
                color: 'white'
              }
            }
          }
        },
        inputEnabled: false,
        allButtonsEnabled: true,
        selected: qmChartOptions.params.chscale,
        buttons: [
          { type : 'day', count : 1, text : '1d'},
          { type : 'day', count : 5, text : '5d' },
          { type : 'week', count : 1, text : '1w' },
          { type : 'week', count : 2, text : '2w' },
          { type: 'month', count: 1, text: '1m' },
          { type: 'month', count: 3, text: '3m' },
          { type: 'month', count: 6, text: '6m' },
          { type: 'ytd',   text: 'YTD' },
          { type: 'year',  count: 1, text: '1y' },
          { type: 'year',  count: 2, text: '2y' },
          { type: 'all',   text: 'All'
        }]
      },
      yAxis: [

      {
        floor: function() {
            if (compare) {
                return 0;
            }
            else
                return 0;
        },
        // tickPositioner: function () {
        //   if (this.dataMin) {
        //         var positions = [],
        //             tick = (this.dataMin),
        //             increment = ((this.dataMax - this.dataMin) / 5);

        //         for (tick; tick - increment <= this.dataMax; tick += increment) {
        //             positions.push(tick.toFixed(3));
        //         }
        //         return positions;
        //       }
        //       return;
        //     },
        labels: {
          formatter: function() {
            if (compare) {
              return (this.value > 0 ? '+' : '') + this.value + '%';
            }
            else
              return '$'+this.value;
          },
          align: 'left',
          style: {
                color: qmChartOptions.params.xyzColor
          }
        },
        title: {
          text: 'Price',
          style: {
            color: qmChartOptions.params.xyzColor
          }
        },
        height: yAxisHeight+'%',
        lineWidth: 0,
        offset: 0,
        lineColor: qmChartOptions.params.xyzColor,
        gridLineColor: qmChartOptions.params.gridColor,
        type: (qmChartOptions.params.chtype=='area' ? 'logarithmic' : 'time' )

      }, {
        labels: {
          align: 'left',
          style: {
            color: qmChartOptions.params.xyzColor
          }
        },
        title: {
          text: 'Volume',
          style: {
            color: qmChartOptions.params.xyzColor
          }
        },
        id: 'VolumePane',
        top: yAxisHeight2+'%',
        height: '15%',
        offset: 0,
        lineWidth: 0,
        lineColor: qmChartOptions.params.xyzColor,
        gridLineColor: qmChartOptions.params.gridColor,
      }],
      xAxis: {
        minRange: 3600 * 1000,
          events: {
              setExtremes: function(e) {
                // e.min = 1421683200000;
                // e.max = 1421683200000;
              //  console.log(e.currentTarget);
              //  console.log(Highcharts.dateFormat(null, e.currentTarget.dataMin ) ,' ', Highcharts.dateFormat(null,e.currentTarget.dataMax));
              //  console.log('<b>Set extremes:</b> e.min: ' + e.currentTarget.min +
                        // ' | e.max: ' + e.currentTarget.max + ' | e.trigger: ' + e.trigger);

                // cMin = e.min;
                // cMax = e.Target.dataMax;

                e.currentTarget.chart.showLoading();
                if(typeof(e.rangeSelectorButton)!== 'undefined')
                {
                  if (e.rangeSelectorButton.type == 'day') {
                    if (qmChartOptions.params.dateDT=='eod') {
                      qmChartOptions.params.dateDT = 'intra';
                      hasSwitchDataType = true;
                      switchDataSet('intra');
                    }
                  }
                  else {
                    if (qmChartOptions.params.dateDT=='intra') {
                      qmChartOptions.params.dateDT = 'eod';
                      hasSwitchDataType = true;
                      switchDataSet('eod');
                    }
                  }
                }

                cMin = e.min;
                cMax = e.currentTarget.dataMax;

              },
              afterSetExtremes: function(z) {
              setTimeout(function() {
                if (hasSwitchDataType) {
                  qmChartOptions.chartRef.xAxis[0].setExtremes(cMin,cMax);
                  //qmChartOptions.chartRef.yAxis[0].setExtremes(0,null);
                  hasSwitchDataType = false;
                  return;
                 }
                  qmChartOptions.chartRef.redraw();
                  qmChartOptions.chartRef.hideLoading();
                }, 350);

               }
          },
          labels: {
          style: {
            color: qmChartOptions.params.xyzColor
          }
        }
      },
      tooltip:{
        hideDelay: 5,
        // valueDecimals: 2,
        useHTML:true,
        // style: {
        //     'margin': '20px'
        // },
        formatter:function(){
          var p = '';

          if (this.point) { // Indicators
            var date = new Date(this.point.x);
            var d2 = (date.getMonth()+1) + '/' + date.getDate()+ '/' + date.getFullYear();

            if (this.series.options.title=='E') {
              return '<b>Earnings</b> <br> On '+ d2 + ', ' + ' EPS Basic: ' + this.point.text[0] + ', Diluted: '+this.point.text[1];
            }
            else if(this.series.options.title=='D') {
              return '<b>Dividends</b> <br> On '+ d2 + ', ' + this.point.series.options.symbol +' paid a dividend of ' + this.point.text + '.'
            }

            else if (this.series.options.title=='S') {
              return '<b>Stock Split</b> <br> On '+ d2 + ', ' + this.point.series.options.symbol +' executed a ' + this.point.text +' split.'
            }
          }
          else if (this.points.length >= 3) { // there is a compare symbol
            var text = Highcharts.dateFormat('%a, %b %e, %l:%M:%S %P',this.x);
            for (var i = this.points.length - 1; i >= 0; i--) {
              p = this.points[i];
              if (i % 2 == 0) {
                text +=
                  '<br/><b><span style="color:'+this.points[i].series.color+'">\u25CF</span> ' + this.points[i].series.name + '</b>'+
                  ' (' + this.points[i].point.y.toFixed(2) + ')'+
                  ' <b>Change:</b> ' + (this.points[i].point.change ? numeral(this.points[i].point.change).format('0.00') : numeral(this.points[i].point.y).format('0.00'))+'%';
              }
            };
            return text;
          }
          else {
            var d     = (qmChartOptions.params.dateDT=='eod') ? Highcharts.dateFormat('%A, %b %e %Y',this.x) : Highcharts.dateFormat('%a, %b %e, %l:%M:%S %P',this.x);
            var c     = this.points[0].series.color;
            var n     = this.points[0].series.name;
            var open  = numeral(this.points[0].point.open).format('0.00');
            var high  = numeral(this.points[0].point.high).format('0.00');
            var low   = numeral(this.points[0].point.low).format('0.00');
            var close = numeral(this.points[0].point.y).format('0.00');
            var vol   = this.points[1] ? numeral(this.points[1].y).format('0,0') : '0';

            if (this.points[0].series.type=='candlestick' || this.points[0].series.type=='ohlc' ) { // OHLC
              return(
                '<table style="width: 60%;border-collapse: collapse;" cellspacing="0" cellpadding="0">'+
                  '<tr>'+
                    '<td colspan="2">'+d+'</td>'+
                  '</tr>'+
                    '<tr><td style="padding:0;margin:0;"><b><span style="color:'+c+'">\u25CF</span>'+n+'</b></td></tr>'+
                    '<tr><td style="padding:0;margin:0;"><b>O:</b></td><td>'+open+'</td></tr>'+
                    '<tr><td style="padding:0;margin:0;"><b>H:</b></td><td>'+high+'</td></tr>'+
                    '<tr><td style="padding:0;margin:0;"><b>L:</b></td><td>'+low+'</td></tr>'+
                    '<tr><td style="padding:0;margin:0;"><b>C:</b></td><td>'+close+'</td></tr>'+
                    '<tr><td style="padding:0;margin:0;"><b>V:</b></td><td>'+vol+'</td></tr>'+
                '</table>'
              );
            }
            else {
              return(
                    d+
                    '<br/><b><span style="color:'+c+'">\u25CF</span>'+n+'</b> (' + close + ')'+
                    '<br/><b>Vol:</b>'+vol
              );
            }
          }
        }
      }
  });


    qmChartOptions.chartRef = $QM('#qm_container').highcharts();
    ldSymbolData(qmChartOptions.params.symbol, '', true);

    if (qmChartOptions.params.qm_compare) {
      ldSymbolData(qmChartOptions.params.qm_compare);
    }
});
