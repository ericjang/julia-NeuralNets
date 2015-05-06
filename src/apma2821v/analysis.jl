function analyze_run(rs::RunResults,time_trace)
	nL = length(rs.data)
	i=1
	figure()
	for (lname, data) in rs.data
		subplot(1,nL,i)
		# 100 randomly selected neurons
		plot_raster(convert(BitArray{2},data["didSpike"][randperm(100),:]))
		title(lname)
		xticks(time_trace)
		i+=1
	end
	show()
end