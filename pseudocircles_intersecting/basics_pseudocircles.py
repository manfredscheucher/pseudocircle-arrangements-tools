# basic functions to work with arrangements of pseudocircles
# (c) manfred scheucher 2016-2023

from itertools import combinations,permutations
from copy import copy


COLORS = range(30)

def color_graph(g):
	arcs = {}
	uncolored = set(g.edges(labels=False))

	faces = g.faces()
	for f in faces:
		assert(len(f) == 4)

	unused_colors = list(reversed(COLORS))
	while uncolored:
		(u,v) = e1 = e0 = uncolored.pop()
		uncolored.add(e0)
		current_color = unused_colors.pop()
		while True:
			e1r = (v,u)
			if e1 in uncolored:
				arcs[e1] = current_color
				uncolored.remove(e1)
			else:
				assert(e1r in uncolored)
				arcs[e1] = current_color
				uncolored.remove(e1r)

			next_face = None
			for f in faces:
				if e1r in f:
					next_face = f
					break
			assert(next_face)
			i = next_face.index(e1r)
			e1 = (u,v) = next_face[i-2] # next_edge
			if e1 == e0: break # cycle done!

	return arcs


# G .. dual graph, v .. triangle
def flip_triangle(G,v):
	nv = G.neighbors(v)
	assert(len(nv) == 3)
	n1,n3,n5 = nv
	c1 = G.edge_label(v,n1)
	c3 = G.edge_label(v,n3)
	c5 = G.edge_label(v,n5)

	n2 = [w for w in G.neighbors(n1) if G.edge_label(n1,w) == c3 and G.has_edge(n3,w)]
	n4 = [w for w in G.neighbors(n3) if G.edge_label(n3,w) == c5 and G.has_edge(n5,w)]
	n6 = [w for w in G.neighbors(n5) if G.edge_label(n5,w) == c1 and G.has_edge(n1,w)]

	assert(len(n2)==1)
	assert(len(n4)==1)
	assert(len(n6)==1)
	n2 = n2[0]
	n4 = n4[0]
	n6 = n6[0]
	G.delete_edge(v,n1)
	G.delete_edge(v,n3)
	G.delete_edge(v,n5)
	G.add_edge(v,n2,c5)
	G.add_edge(v,n4,c1)
	G.add_edge(v,n6,c3)
	return G


def all_possible_triangle_flips(g,digonfree=False,great=False):
	if great:
		diam = g.diameter()
		dist = g.distance_all_pairs()
		for v in g: 
			assert(max(dist[v].values()) == diam) # arrangement is great

	for v in g.vertices():
		if g.degree(v) == 3:
			g2 = g.copy()
			g2 = flip_triangle(g2,v)

			if great:
				v_antipodal = [w for w in g.vertices() if dist[v][w] == diam]
				assert(len(v_antipodal) == 1)
				g2 = flip_triangle(g2,v_antipodal[0])
			
			if not digonfree or 2 not in g2.degree(): 
				yield g2

