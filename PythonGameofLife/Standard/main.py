import patterns, views
import time
#start=time.time()
gen=1000
#for i in range(5):
views.CursesView(patterns.get_pattern("Bunnies"), gen=gen).show()
    #print(f"{i+1} done")
#end=time.time() 
#print(f"Standard took {(end-start)/5} for {gen} iterations") 