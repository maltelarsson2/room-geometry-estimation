import pyroomacoustics as pra
import open3d as o3d
import numpy as np
import matplotlib.pyplot as plt
import time
from scipy.io import wavfile
import json
import plyfile_utils.getMaterialLabels as roomMaterials


def getCuboidGt(id):
    cuboidFile = "PATH/TO/layouts_train.json"
    with open(cuboidFile) as f:
        d = json.load(f)
        R = np.asarray(d[id]["R"])
        t = np.asarray(d[id]["t"])
        s = np.asarray(d[id]["s"])
        return R, t, s

def change_orientation(corners):
    corners = corners.transpose()
    return corners[::-1].transpose()


def create_box(corner0, corner1, inside, R = None, t = None, mean_shift=True):
    inside_point = (corner0+corner1)/2
    all_corners = []

    all_corners.append(np.asarray([[corner0[0],corner0[1],corner0[2]], [corner0[0],corner0[1],corner1[2]], [corner0[0], corner1[1], corner1[2]], [corner0[0],corner1[1],corner0[2]]]).transpose())
    all_corners.append(np.asarray([[corner0[0],corner0[1],corner0[2]], [corner0[0],corner1[1],corner0[2]], [corner1[0], corner1[1], corner0[2]], [corner1[0],corner0[1],corner0[2]]]).transpose())
    all_corners.append(np.asarray([[corner0[0],corner0[1],corner0[2]], [corner0[0],corner0[1],corner1[2]], [corner1[0], corner0[1], corner1[2]], [corner1[0],corner0[1],corner0[2]]]).transpose())
    all_corners.append(np.asarray([[corner1[0],corner0[1],corner0[2]], [corner1[0],corner0[1],corner1[2]], [corner1[0], corner1[1], corner1[2]], [corner1[0],corner1[1],corner0[2]]]).transpose())
    all_corners.append(np.asarray([[corner0[0],corner0[1],corner1[2]], [corner0[0],corner1[1],corner1[2]], [corner1[0], corner1[1], corner1[2]], [corner1[0],corner0[1],corner1[2]]]).transpose())
    all_corners.append(np.asarray([[corner0[0],corner1[1],corner1[2]], [corner1[0],corner1[1],corner1[2]], [corner1[0], corner1[1], corner0[2]], [corner0[0],corner1[1],corner0[2]]]).transpose())

    if R is not None:
        middle_point = (corner0+corner1)/2
        
        for i in range(6):
            if mean_shift:
                all_corners[i] -= np.expand_dims(middle_point,1)
            all_corners[i] = R.transpose()@(all_corners[i]-np.expand_dims(t, 1))

    for i in range(6):
        n = np.cross(all_corners[i][:, 2]-all_corners[i][:, 1], all_corners[i][:, 0]-all_corners[i][:, 1])
        is_inside = np.dot(n, inside_point-all_corners[i][:, 0]) < 0
        if (inside and not is_inside) or (not inside and is_inside):
            all_corners[i] = change_orientation(all_corners[i])

    return all_corners

def createRoom2(room_filename, room_id, fs = 48000):
    mesh = o3d.io.read_triangle_mesh(room_filename)
    mesh.compute_vertex_normals()
    # o3d.visualization.draw(mesh, raw_mode=True)
    verts = np.asarray(mesh.vertices)
    triangs = np.asarray(mesh.triangles)
    walls = []
    material1 = pra.Material(energy_absorption=0.5, scattering=0.0)
    for i in range(len(triangs)):
    # for i in range(4000):
        corners = []
        for j in range(len(triangs[i])):
            corners.append(verts[triangs[i][j],:])
        wall = pra.wall_factory(corners=np.asarray(corners).transpose(), absorption=material1.absorption_coeffs, scattering=material1.scattering_coeffs)
        walls.append(wall)
        wall = pra.wall_factory(corners=change_orientation(np.asarray(corners).transpose()), absorption=material1.absorption_coeffs, scattering=material1.scattering_coeffs)
        walls.append(wall)

    R, t, s = getCuboidGt(room_id)

    all_corners2 = create_box(np.asarray([0, 0, 0]), s, True, R, t)
    # all_corners2 = create_box(np.asarray([0, 0, 0]), s + [2, 2, 2], True, R, t)
    for i in range(6):
        wall = pra.wall_factory(corners=np.asarray(all_corners2[i]), absorption=material1.absorption_coeffs, scattering=material1.scattering_coeffs)
        walls.append(wall)


        
    room = pra.Room(walls=walls, fs=fs, max_order=1, air_absorption=True)

    return room, R, t, s


def createRoom_materials(room_filename, path_to_semantic_room, room_id, fs = 48000):
    mesh = o3d.io.read_triangle_mesh(room_filename)
    mesh.compute_vertex_normals()
    # o3d.visualization.draw(mesh, raw_mode=True)
    verts = np.asarray(mesh.vertices)
    triangs = np.asarray(mesh.triangles)
    absorptions = roomMaterials.getAbsorptionForVertices(room_id, verts.transpose(), path_to_semantic_room)
    walls = []
    material1 = pra.Material(energy_absorption=0.1, scattering=0.0)
    material2 = pra.Material(energy_absorption=0.75, scattering=0.0)
    for i in range(len(triangs)):
    # for i in range(4000):
        corners = []
        faceAbsorbtions = []
        for j in range(len(triangs[i])):
            corners.append(verts[triangs[i][j],:])
            faceAbsorbtions.append(absorptions[triangs[i][j]])
        faceAbsorbtion = max(faceAbsorbtions)
        if faceAbsorbtion == roomMaterials.Absorption.HARD.value:
            material_cur = material1
        elif faceAbsorbtion == roomMaterials.Absorption.MEDIUM.value:
            material_cur = material1
        else:
            material_cur = material2
            
        wall = pra.wall_factory(corners=np.asarray(corners).transpose(), absorption=material_cur.absorption_coeffs, scattering=material_cur.scattering_coeffs)
        walls.append(wall)
        wall = pra.wall_factory(corners=change_orientation(np.asarray(corners).transpose()), absorption=material_cur.absorption_coeffs, scattering=material_cur.scattering_coeffs)
        walls.append(wall)

    R, t, s = getCuboidGt(room_id)

    all_corners2 = create_box(np.asarray([0.05, 0.05, 0.05]), s, True, R, t)
    # all_corners2 = create_box(np.asarray([0, 0, 0]), s + [2, 2, 2], True, R, t)
    for i in range(6):
        wall = pra.wall_factory(corners=np.asarray(all_corners2[i]), absorption=material1.absorption_coeffs, scattering=material1.scattering_coeffs)
        walls.append(wall)


        
    room = pra.Room(walls=walls, fs=fs, max_order=1, air_absorption=True)

    return room, R, t, s

