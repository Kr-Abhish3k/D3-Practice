# https://bl.ocks.org/gordlea/27370d1eea8464b04538e6d8ced39e89
window.lineChart = class lineChart 
	constructor:->
		@margin = {
			top: 50,
			right: 50,
			bottom: 50,
			left: 50
		}

		@jsondata = @getJSONdata()

		#@height = window.innerHeight - @margin.top - @margin.bottom #window's inner height
		@height = 500 - @margin.top - @margin.bottom 
		
		@parseDate = d3.timeParse("%Y")

		# Add Tool tip Div to chart
		@toolTipDiv = d3.select('.drawBoard').append('div').attr('class', 'toolTip').style('opacity', 0)	

		#1. attach SVG to body
		@svg  = d3.select(".drawBoard").append("svg")
				.attr("class","lineChart")
				.attr("height", @height + @margin.top + @margin.bottom )

		@gContainer = @svg.append("g")
						.attr("class","gContainer")
						.attr("transform" , "translate( "+ @margin.left + " , " + @margin.top + ")" )			

		#2. X Scale
		@xAxis = d3.axisBottom()
		@drawXaxis =@gContainer.append("g").attr("class", "xAxis").attr("transform", "translate( 0, " +  @height + ")" )

		that=this 
		@xScale = d3.scaleTime()
					.domain(d3.extent(@jsondata , (d)-> d.year = that.parseDate(d.year))) #input			

		#3. Y Scale 
		@yAxis = d3.axisLeft()
		@drawYaxis = @gContainer.append("g").attr("class", "yAxis") 
		@yScale = d3.scaleLinear()
					.domain([0, d3.max(@jsondata, (d)->d.count)+1000]) #input
					.range([@height , 0])  #output	
		@yAxis.scale(@yScale)			

		@drawYaxis.call(@yAxis)				



		#7. To add horizontal lines on graph
		@gContainer.append("g")
			.attr("class","grid")

	init:->
		@setSvgDimensions()

		$(window).on 'resize': =>
			@setSvgDimensions()
			

		
	setSvgDimensions:()->
		@width = window.innerWidth - @margin.left - @margin.right #window's inner width
		@svg.attr("width", @width + @margin.left + @margin.right )
		
		@xScale.range([0, @width])
		@xAxis.scale(@xScale)
		@drawXaxis.call(@xAxis)

		@connectPoints()
		@plotPoints()
		@drawHorizontalGridLines(@width)
			

	connectPoints:() ->
		that = this
		#4.d3's line generator
		@line = d3.line()
				.x((d)-> that.xScale(d.year))	#set the x co-ordinates values for the line generator
				.y((d)-> that.yScale(d.count))   #set the y co-ordinates values for the line generator 
				.curve(d3.curveMonotoneX) # apply smoothing to the line
				

		#5. Append Path , bind the data and call the line generator
		@gContainer.selectAll('.line').remove()
		@gContainer.append("path")
			.datum(@jsondata) #Bind Data to line
			.attr("class", "line")
			.attr("d" , @line) #calls the line generator

		
	plotPoints:() ->
		#6. Append a circle for each datapoint
		@gContainer.selectAll('.dot').remove()				
		that = this
		@gContainer.selectAll(".dot")
			.data(@jsondata)
			.enter()
			.append("circle")
			.attr("class","dot")
			.attr("cx", (d)-> that.xScale(d.year))	
			.attr("cy", (d)-> that.yScale(d.count))
			.attr("r",5)
			.style("fill","#7a7a7a")
			.attr("stroke","#fff")
			.on("mouseover",(d)->
				d3.select(this)
					.attr("r",8)
					.style("fill",(d)->"#fff")
					.attr("stroke",'#36648b')
					.attr("stroke-width",5)	

				leftPosition = 	$(this).attr("cx")
				topPosition = $(this).attr("cy")

				boxWidth = $(".drawBoard").width()
				boxHeight = $(".drawBoard").height()

				#when tooltip lies on right edge , pull it in
				if((boxWidth - leftPosition) < 100) 
					leftPosition = leftPosition - (boxWidth - leftPosition)

					
				#when point is on x=0 ; i.e. y-axis	
				if(parseInt(leftPosition) == 0)
					leftPosition = 25

				#when point is at top of chart
				if(parseInt(topPosition) < 25)
					topPosition = 60


				that.toolTipDiv.transition().duration(200).style('opacity',0.9)	
				that.toolTipDiv.html("Year : "+d.year.getFullYear()+"<br>"+"Count : "+d.count)
								.style("left",leftPosition+"px")
								.style("top",topPosition+"px")
			)
			.on("mouseout", (d)->
				d3.select(this)
					.attr("r",5)
					.style("fill","#7a7a7a")
					.attr("stroke",'#fff')	
					.attr("stroke-width",1)	

				that.toolTipDiv.transition().duration(500).style('opacity',0)	
			)

	
	drawHorizontalGridLines:(width)->
		#add horizontal lines to graph parallel to x-axis
		@gContainer.select(".grid").call(d3.axisLeft(@yScale).ticks(10).tickSize(-width).tickFormat(''))

	getJSONdata:() ->
		dataArray =[]
		$.ajax(
			type: "GET",
			async: false,
			url: "./lineChart.json",
			data: { get_param: 'value' },
			dataType: "json",
			success: (data) ->
				dataArray = data
		)
		dataArray
	



$(document).ready -> 
	chart = new lineChart()
	chart.init()