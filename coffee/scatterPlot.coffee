window.scatterPlot = class scatterPlot
	constructor:->
		@width = 500
		@height = 250
		@padding = 20
		@xPadding = 20
		@yPadding = 20

		@dataset = [
				[5, 20],
				[480, 90], 
				[250, 50], 
				[100, 33],
				[330, 95],
				[410, 12], 
				[475, 44], 
				[25, 67], 
				[85, 21], 
				[220, 88]
			]
		
		@svg = d3.select(".drawBoard")
				.append("svg")
				.attr("class","scatterPlot")
				.attr("height",@height)
				.attr("width", @width)


		@xScale = d3.scaleLinear()
					.domain([0, d3.max(@dataset , (d)->	d[0])])
					.range([@padding, @width - @padding * 2])
		

		@yScale = d3.scaleLinear()
					.domain([0, d3.max(@dataset , (d)->	d[1])])
					.range([@height - @padding, @padding])


		@xAxis = d3.axisBottom(@xScale).ticks(10)	
		@yAxis = d3.axisLeft(@yScale).ticks(5)		
						


	init:->
		@plotPoints()
		@addText()
		@addAxes()

	addAxes: () ->
		@svg.append("g")
			.attr("class","xAxis")
			.attr("transform" , "translate(0," + (@height - @padding) + ")") 	
			.call(@xAxis)

		@svg.append("g")
			.attr("class","yAxis")
			.attr("transform" , "translate(" + @padding + ", 0)")	
			.call(@yAxis)	


	plotPoints:() ->
		that=this
		@svg.selectAll("circle")
		.data(@dataset)
		.enter()
		.append("circle")
		.attr('cx', (d) ->	
			that.xScale(d[0])
		) 
		.attr('cy', (d) ->	
			that.yScale(d[1])
		) 
		.attr('r',5)
	
	addText:()->
		that = this
		@svg.selectAll('text')
		.data(@dataset)
		.enter()
		.append('text')
		.text((d)=>
			"( "+d[0]+","+d[1]+")"
		)
		.attr("x", (d)=>
			that.xScale(d[0]) #d[0] - 8
		)
		.attr("y", (d)=>
			that.yScale(d[1]) #d[1] - 5
		)
		.attr("font-family", "sans-serif")
		.attr("font-size", "11px")
		.attr("fill", "red")



$(document).ready ->
	scatterPlotObj = new scatterPlot()
	scatterPlotObj.init()

