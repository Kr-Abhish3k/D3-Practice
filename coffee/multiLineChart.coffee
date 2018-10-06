window.multiLineChart = class multiLineChart
    constructor:->  
        @data = [
            {"Org":"IBM","price": "202","year": "2000"},
            {"Org":"IBM","price": "215","year": "2001"}, 
            {"Org":"IBM","price": "179","year": "2002"}, 
            {"Org":"IBM","price": "315","year": "2003"}, 
            {"Org":"IBM","price": "134","year": "2004"}, 
            {"Org":"IBM","price": "289","year": "2010"}
                        
            {"Org":"AMAZON","price": "224","year": "2000"}, 
            {"Org":"AMAZON","price": "225","year": "2001"},
            {"Org":"AMAZON","price": "279","year": "2002"}, 
            {"Org":"AMAZON","price": "299","year": "2003"}, 
            {"Org":"AMAZON","price": "234","year": "2004"}, 
            {"Org":"AMAZON","price": "376","year": "2008"}   
            
            {"Org":"MSFT","price": "100","year": "2000"}, 
            {"Org":"MSFT","price": "106","year": "2001"},
            {"Org":"MSFT","price": "199","year": "2002"}, 
            {"Org":"MSFT","price": "196","year": "2004"}, 
            {"Org":"MSFT","price": "198","year": "2006"}, 
            {"Org":"MSFT","price": "118","year": "2009"}

            {"Org":"AAPL","price": "259","year": "2000"}, 
            {"Org":"AAPL","price": "286","year": "2003"},
            {"Org":"AAPL","price": "339","year": "2005"}, 
            {"Org":"AAPL","price": "310","year": "2007"}, 
            {"Org":"AAPL","price": "261","year": "2008"}, 
            {"Org":"AAPL","price": "254","year": "2010"}               
        ]

        @lineColor = [" #152642", " #484848","#f76c5e" ," #ca2e55" ,"#84b4c0", "#7a4948","#cebfcd", "#2c3749"]

        ###@dataGroup = [
            {
                "key":"IBM",
                "values":[
                           {"price": "202","year": "2000"}, {"price": "215","year": "2001"}, 
                           {"price": "179","year": "2002"}, {"price": "315","year": "2003"}, 
                           {"price": "134","year": "2003"}, {"price": "289","year": "2010"}
                        ] 
            },
            {
                "key":"AMAZON",
                "values":[
                            {"price": "204","year": "2000"}, {"price": "225","year": "2001"},
                            {"price": "279","year": "2002"}, {"price": "299","year": "2003"}, 
                            {"price": "234","year": "2003"}, {"price": "276","year": "2010"}
                        ] 
            }
        ]###

        @dataGroup = d3.nest()
                       .key((d)-> d.Org )
                       .entries(@data)
        
        @margin = {
                top: 50,
                bottom: 50,
                left: 50,
                right: 25
            }

        
        @height = 500 - @margin.top - @margin.bottom 
        @parseDate = d3.timeParse("%Y")
        #@dataGroup = @getJSONdata()

        ###
        @price =[]
        @year = []
        that = this
        @dataGroup.forEach((data)->
                getPrice = (data.values).map (currVal)->{price:currVal.price}
                getYear =  (data.values).map (currVal)->{year:currVal.year}
                that.price = that.price.concat(getPrice)
                that.year =  that.year.concat(getYear)
            )
        ###    


        #add tool tip div to the chart
        @toolTipDiv = d3.select(".drawBoard")
                        .append("div")
                        .attr("class","toolTip")
                        .style("display","none")
                        

                         
        @label = d3.select(".drawBoard")
                    .append("div")
                    .attr("class","label")
                    #.style("opacity",1)
                    #.html("<span> IBM </span> <span> AMAZON </span> <span> MSFT </span> <span> AAPL </span>")     
        that = this            
        @dataGroup.forEach((data,index)->
                    d3.select(".label")       
                        .append("span")
                        .attr("class",data.key)
                        .style("background",that.lineColor[index])    

                    d3.select(".label")        
                        .append("p")
                        .attr("class",data.key)
                        .text(data.key)
                        .style("color",that.lineColor[index])    
            )                       

        #add svg
        @svg = d3.select(".drawBoard")
                 .append("svg")                              
                 .attr("class","multiLineChart")
                 .attr("height", @height + @margin.top + @margin.bottom )
                 #.attr("width", window.innerWidth - @margin.right)
                 
        @gContainer=@svg.append("g")
                        .attr("class", "gContainer")
                        .attr("transform" , "translate( "+ 35 + " , " + @margin.top + ")" )    

        #x-scale 
        that = this
        @xScale = d3.scaleTime()
                    .domain(d3.extent(@data , (d)->d.year = that.parseDate(d.year))) 
                    #.range([0 , @width])            

        @drawXaxis = @gContainer.append('g').attr("class","xAxis").attr("transform", "translate( 0, " +  @height + ")" )
        @xAxis = d3.axisBottom().scale(@xScale)
        @drawXaxis.call(@xAxis)    

        #y-scale
        @yScale = d3.scaleLinear()
                    .domain([0,d3.max(@data, (d)->d.price)])
                    .range([@height , 0])
        
        
        @drawYaxis = @gContainer.append('g').attr("class","yAxis")                            
        @yAxis = d3.axisLeft().scale(@yScale) 
        @drawYaxis.call(@yAxis)  

        #7. To add horizontal lines on graph
        @gContainer.append("g")
            .attr("class","grid") 

    init:->
        @setSvgDimensions()

        $(window).on 'resize':=>
            @gContainer.selectAll(".line").remove()
            @gContainer.selectAll(".dot").remove()
            @setSvgDimensions()
        
    setSvgDimensions:()->
        @width =  @width = window.innerWidth - @margin.left - @margin.right 
        @svg.attr("width", @width + @margin.left + @margin.right ) 

        @xScale.range([0,@width])
        @xAxis.scale(@xScale)
        @drawXaxis.call(@xAxis)

        @generateLine()
        @plotPoints()
        @drawHorizontalGridLines(@width)



    getJSONdata:() ->
        dataArray =[]
        $.ajax(
            type: "GET",
            async: false,
            url: "./MultiLineData.json",
            data: { get_param: 'value' },
            dataType: "json",
            success: (data) ->
                dataArray = data
        )
        dataArray
    
    generateLine:()->
        that = this
        @line = d3.line()
                  .x((d)-> that.xScale(d.year))
                  .y((d)-> that.yScale(d.price)) 
                  .curve(d3.curveCardinal)
        
        that = this          
        @dataGroup.forEach((data , index)-> 
                that.gContainer.append("path")
                           .datum(data.values)
                           .attr("class","line")
                           .attr("org",data.key)
                           .attr("d",that.line)
                           .attr("fill","none")
                           .attr("stroke",that.lineColor[index]) 
                           .attr("stroke-width",2)
                           .attr("stroke-opacity",0.4)
                           .on("mouseover",(d)->
                                that.onMouseover(this , index)
                                that.showLabel(data.key)

                            )
                           .on("mouseout" , (d)->
                                that.onMouseout(this)
                                that.fadeLabel(data.key)
                            )

        )

    plotPoints:()->
        that = this
        @dataGroup.forEach((data,index)->
                that.gContainer.selectAll("dot")
                   .data(data.values)           
                   .enter()
                   .append("circle")
                   .attr("class","dot")
                   .attr("org",data.key) 
                   .attr("cx",(d)->that.xScale(d.year))
                   .attr("cy",(d)->that.yScale(d.price))
                   .attr("r",5)
                   .attr("fill","#fff") 
                   .attr("stroke",that.lineColor[index])
                   .attr("stroke-opacity",0.4) 
                   .on("mouseover",(d)->
                                that.onMouseover(this , index)

                                leftPosition = parseInt($(this).attr("cx"))
                                topPosition = parseInt($(this).attr("cy"))

                                boxWidth = parseInt($(".drawBoard").width())
                                boxHeight = parseInt($(".drawBoard").height())
                                toolTipWidth = $(".toolTip")

                                diff = (leftPosition+125) - boxWidth

                                
                                #when tooltip lies on right edge , pull it in
                                if(diff > 10) 
                                        leftPosition = (leftPosition - diff)-10
                                        


                                #when point is on x=0 ; i.e. y-axis
                                if(leftPosition == 0)
                                        leftPosition = 35

                                #when point is at top of chart
                                if(topPosition < 25)  
                                      topPosition = 60

                                that.toolTipDiv.transition().duration(200).style("display","block")
                                that.toolTipDiv.html("Year : "+d.year.getFullYear()+"<br>"+"Price:"+d.price)
                                               .style("left",leftPosition+"px")
                                               .style("top",topPosition+"px")
                                               .style("background",that.lineColor[index])

                                that.showLabel(data.key)               
                               
                            )
                   .on("mouseout" , (d)->
                                that.onMouseout(this)

                                that.toolTipDiv.transition().duration(500)
                                               .style("display","none")
                                               
                                that.fadeLabel(data.key)               
                            )
            )

    onMouseover:(element , index)->
                type = d3.select(element).attr("org")
                d3.selectAll("[org="+type+"]")
                  .attr("stroke-opacity",0.9)
                  .attr("fill-opacity",1)
                  .attr("stroke-opacity",0.9)
                  .filter("circle")
                  .attr("fill",@lineColor[index])
                   
    onMouseout:(element)-> 
                type = d3.select(element).attr("org")
                d3.selectAll("[org="+type+"]")
                  .attr("stroke-opacity",0.4) 
                  .attr("fill-opacity",0.4)
                  .attr("stroke-opacity",0.4)
                  .filter("circle")
                  .attr("fill","#fff")
                  .attr("fill-opacity",1)  

    drawHorizontalGridLines:(width)->
        #add horizontal lines to graph parallel to x-axis
        @gContainer.select(".grid").call(d3.axisLeft(@yScale).ticks(10).tickSize(-width).tickFormat(''))  

    showLabel:(element)->
        d3.selectAll("[class="+element+"]")
          .style("opacity",1)  

    fadeLabel:(element)-> 
        d3.selectAll("[class="+element+"]")
          .style("opacity",0.4)     
        
                
                     

$(document).ready ->
    multilineChart = new multiLineChart()
    multilineChart.init()