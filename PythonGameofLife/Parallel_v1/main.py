import patterns, views
import time
gen=100
views.CursesView(patterns.get_pattern("Bunnies"), gen=gen).show()
