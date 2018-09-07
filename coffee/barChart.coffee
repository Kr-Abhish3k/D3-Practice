window.D3 = class D3
	constructor:->
		@dataset = []
		@width = 500
		@height = 150

		@max = Math.floor(Math.random()* 10)
		for i in [0..@max]
			@dataset.push(Math.round(Math.random() * 50))
		console.log("data ="+@dataset)	

		@barWidth = 500 / @dataset.length 

	init:->	
		@addElements()


	addElements:()-> 
		svg = d3.select(".drawBoard").append("svg")
				.attr("class","barChart")
				.attr("width",@width)
				.attr("height",@height)

		svg.selectAll("rect")
		.data(@dataset)
		.enter()
		.append("rect")
		.attr("class","bar")
		.attr("x",(d,i) =>
			return (i * (500 / @dataset.length)) 
		)
		.attr("y",(d)=>
			return (@height - d)
		)
		.style("width", (d)=>
			return (500 / @dataset.length - 2) 
		)	
		.style("height", (d)=>
			return (d*10) + "px"
		)
		.attr("fill", (d)=>
			#"hsl(" + (Math.random() * 360) + ",100%,50%)"
			@getRandomColor()
		)

		svg.selectAll("text")
		.data(@dataset)
		.enter()
		.append("text")
		.text((d)=>
			return d
		)
		.attr('x' ,(d,i)=>
			return (i * (500 / @dataset.length)) + (@barWidth/2)		
		)
		.attr('y' , (d,i)=>
			return @height - (d-15) + 5
		)
		.attr("fill" , "white")	

	getRandomColor:()->
		letters = '0123456789ABCDEF'
		color = '#'
		for i in [0..5]
			color += letters[Math.floor(Math.random() * 16)]	
		console.log("color = "+color)
		return color


$(document).ready ->
	D3obj = new D3()
	D3obj.init()		 	
