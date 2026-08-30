import pymeshlab
ms = pymeshlab.MeshSet()

mesh_path = "path/to/mesh"
reduced_mesh_path = "path/to/save/mesh"
ms.load_new_mesh(mesh_path)
ms.meshing_decimation_quadric_edge_collapse(targetfacenum = 20000, preservenormal = True, planarquadric = True)
ms.save_current_mesh(reduced_mesh_path)

