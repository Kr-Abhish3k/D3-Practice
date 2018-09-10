# https://bl.ocks.org/d3noob/119a138ef9bd1d8f0a8d57ea72355252
window.areaChart = class areaChart
	constructor:->
		@margin = {
			top: 50,
			right: 50,
			bottom: 50,
			left: 50
		}

		@jsondata = @getJSONdata()
		@width = window.innerWidth - @margin.left - @margin.right 
		@height = window.innerHeight - @margin.top - @margin.bottom
		@parseDate = d3.timeParse("%Y")

		# X Scale
		that=this 
		@xScale = d3.scaleTime()
					.domain(d3.extent(@jsondata , (d)-> d.year = that.parseDate(d.year))) 
					.range([0,@width])  

		#Y Scale
		@yScale = d3.scaleLinear()
					.domain([0,d3.max(@jsondata ,(d)->d.count)])
					.range([@height, 0])

		#1.Add SVG 
		@svg = d3.select(".drawBoard")
					.append("svg")
					.attr("class","areaChart")
					.attr("height",@height + @margin.top + @margin.bottom )
					.attr("width",@width + @margin.left + @margin.right )
					.append("g")
					.attr("class","gContainer")
					.attr("transform" , "translate( "+ @margin.left + " , " + @margin.top + ")" )		


	init:->
		@addAxes()
		#@plotPoints
		#@drawLine


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

	addAxes:()->
		#2.add x-scale
		@svg.append("g")
			.attr("class", "xAxis")
			.attr("transform", "translate( 0, " +  @height  + ")" ) 		
			.call(d3.axisBottom(@xScale))
		
		#3.add y-scale
		@svg.append("g")
			.attr("class","yAxis")
			.call(d3.axisLeft(@yScale))		



$(document).ready ->
	areaChartObj = new areaChart()
	areaChartObj.init()