# Author: Manfred Scheucher 2016-2023

from itertools import combinations,permutations
from copy import copy,deepcopy
import networkx as nx


IPE_COLORS = range(30)


def compute_fingerprint(arcs,arcs_with_color=None):
	if arcs_with_color == None:
		arcs_with_color = compute_circles_of_arcs(arcs)

	colors = list(set(arcs.values()))
	color_val = {c:1+colors.index(c) for c in colors}

	fingerprint = {}
	n = len(colors)
	for c in colors:
		cv = color_val[c]
		fingerprint[cv] = []
		for j in range(2*(n-1)):
			# re-check order
			ui,vi = arcs_with_color[c][j-1]
			uj,vj = arcs_with_color[c][j]
			assert ((ui,uj) in arcs and (vi,vj) in arcs) or ((uj,ui) in arcs and (vj,vi) in arcs)
			if (ui,uj) in arcs:
				fingerprint[cv].append(+color_val[arcs[(ui,uj)]])
			else:
				fingerprint[cv].append(-color_val[arcs[(uj,ui)]])

	return fingerprint


def fingerprint_to_string(fingerprint):
	return '\n'.join(str(c)+':'+' '.join(str(x).rjust(2) for x in fingerprint[c]) for c in fingerprint)


def color_graph(g):
	arcs = {}
	uncolored = set(g.edges(labels=False))
	
	faces = g.faces()
	for f in faces:
		assert(len(f) == 4)

	unused_colors = list(reversed(IPE_COLORS))
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


def compute_circles_of_arcs(arcs):
	colors = list(set(arcs.values()))
	n = len(colors)

	# sort arcs for color
	arcs_with_color = {}
	for c in colors:
		arcs_with_color[c] = []

	for a in arcs:
		arcs_with_color[arcs[a]].append(a)

	for c in colors:
		assert(len(arcs_with_color[c]) == 2*(n-1))

	for c in colors:
		for i in range(2*(n-1)-1):
			ui,vi = arcs_with_color[c][i]
			found = False
			for j in range(i+1,2*(n-1)):
				uj,vj = arcs_with_color[c][j]
				if ((ui,uj) in arcs and (vi,vj) in arcs) or ((uj,ui) in arcs and (vj,vi) in arcs):
					# in both cases exchange
					arcs_with_color[c][i+1],arcs_with_color[c][j] = arcs_with_color[c][j],arcs_with_color[c][i+1]
					found = True
					break
			assert(found)

		# all circles must have the same orientation
		if c != colors[0]: 
			for j in range(2*(n-1)):
				ui,vi = arcs_with_color[c][j-1]
				uj,vj = arcs_with_color[c][j]
				if (ui,uj) in arcs and arcs[(ui,uj)] == colors[0]:
					assert((vi,vj) in arcs_with_color[colors[0]])
					assert((ui,uj) in arcs_with_color[colors[0]])
					iv = arcs_with_color[colors[0]].index((vi,vj))
					iu = arcs_with_color[colors[0]].index((ui,uj))
					divu = (iu-iv) % (2*n-2)
					assert(divu in [1,2*n-3])
					if divu != 1:
						# change direction of current circle
						arcs_with_color[c].reverse()
					break

	# re-check order
	for c in colors:
		for j in range(2*(n-1)):
			ui,vi = arcs_with_color[c][j-1]
			uj,vj = arcs_with_color[c][j]
			assert ((ui,uj) in arcs and (vi,vj) in arcs) or ((uj,ui) in arcs and (vj,vi) in arcs)

	return arcs_with_color


def common_intersection(vertices,arcs,outer_vertex=None):
	partitions = compute_partitions(vertices,arcs)
	possible_separations = []
	for u in vertices:
		if outer_vertex != None and u != outer_vertex: 
			continue
		if partitions[u]:
			assert(len(partitions[u]) == 1)
			v = list(partitions[u])[0]
			possible_separations.append((u,v))

	return possible_separations

	
def compute_partitions(vertices,arcs):
	colors = list(set(arcs.values()))
	component = dict()
	component_inverse = dict()
	for c1 in colors:
		arcs2 = [e for e in arcs if arcs[e] != c1]
		component[c1],component_inverse[c1] = connected_components(vertices,arcs2)
		for i in range(2):
			component_inverse[c1][i] = set(component_inverse[c1][i])

	others = {}
	for u in vertices:
		others[u] = set(vertices)
		for c1 in colors:
			if component[c1][u] == 0:
				assert(u not in component_inverse[c1][1])
				others[u] &= component_inverse[c1][1]
			else:
				assert(u not in component_inverse[c1][0])
				others[u] &= component_inverse[c1][0]
			
		for v in others[u]:
			for c1 in colors:
				assert(component[c1][u] != component[c1][v])

		assert(len(others[u]) <= 1)
	return others


def connected_components(vertices,edges):
	for v in vertices:
		assert(type(v) == int)
	
	predecessor = {v:v for v in vertices}
	def find_predecessor_(v):
		while True:
			c = predecessor[v]
			if c == v: 
				return c
			else:
				v = c

	for (u,v) in edges:
		pu = find_predecessor_(u)
		pv = find_predecessor_(v)
		if pu != pv:
			if pu > pv:
				predecessor[pu] = pv
			else:
				predecessor[pv] = pu

	component = {v:find_predecessor_(v) for v in vertices}
	component_inverse = [[v for v in vertices if component[v] == c] for c in set(component.values())]
	return component,component_inverse
