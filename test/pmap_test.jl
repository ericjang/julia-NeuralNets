# @everywhere f(s,count)=(println("process id = $(myid()) s = $s count = $count");repeat(s,count))
# pmap((a1,a2)->f(a1,a2),{"a","b","c"},{2,1,3})



@everywhere type Foo
	r
end

@everywhere function update!(el,n)
	el.r = -1 * n
end


x = [Foo(2*i) for i=1:1000]

d = [i=>i for i=1:1000]
samples_pmap = pmap(update!,x,d)
samples = vcat(samples_pmap[1],samples_pmap[2],samples_pmap[3],samples_pmap[4])
print(x)