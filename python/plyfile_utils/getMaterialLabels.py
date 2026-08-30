from plyfile import PlyData, PlyElement
import numpy as np
from enum import Enum

class Absorption(Enum):
    HARD = 1
    MEDIUM = 2
    SOFT = 3
    UNKNOWN = 4


def getLabelIds():
    #This is part of the scannet++ dataset
    filename = "/PATH/TO/scannetpp/data/metadata/semantic_classes.txt"
    labelToInd = {}
    indToLabel = {}
    with open(filename, "r") as f:
        index = 0
        for line in f:
            labelToInd[line.strip()] = index
            indToLabel[index] = line.strip()
            index += 1
    return labelToInd, indToLabel


def getAbsorption():
    #File in the echo dataset.
    filename = "/PATH/TO/semantic_classses_absorption.txt"
    labelToAbsorption = {}
    with open(filename, "r") as f:
        for line in f:
            line = line.strip()
            if line[-1] == "h":
                labelToAbsorption[line[:-1].strip()] = Absorption.HARD.value
            elif line[-1] == "s":
                labelToAbsorption[line[:-1].strip()] = Absorption.SOFT.value
            elif line[-1] == "t":
                labelToAbsorption[line[:-1].strip()] = Absorption.MEDIUM.value
    return labelToAbsorption




def getLabelsForVertices(room_id, vertices, path_to_semantic_room):
    plydata = PlyData.read(path_to_semantic_room)

    label_list = plydata['vertex']['label']
    original_vertices = np.zeros((3, len(plydata['vertex']['x'])))
    original_vertices[0, :] = plydata['vertex']['x']
    original_vertices[1, :] = plydata['vertex']['y']
    original_vertices[2, :] = plydata['vertex']['z']

    labels = np.zeros(np.size(vertices, 1))
    for vert_ind in range(np.size(vertices, 1)):
        vert = vertices[:, [vert_ind]]
        closest_vert = np.argmin(np.linalg.norm(original_vertices-vert, axis=0))
        labels[vert_ind] = label_list[closest_vert]
    return labels


def getAbsorptionForVertices(room_id, vertices, path_to_semantic_room):
    label_inds = getLabelsForVertices(room_id, vertices, path_to_semantic_room)
    _, indToLabel = getLabelIds()
    labelToAbsorption = getAbsorption()
    absorptionLevels = np.zeros(label_inds.shape)
    numNeg = 0
    numPos = 0
    for i in range(np.size(vertices, axis=1)):
        if label_inds[i]<0:
            absorptionLevels[i] = Absorption.UNKNOWN.value
            numNeg += 1
        else:
            numPos += 1
            labelName = indToLabel[label_inds[i]]
            if labelName in labelToAbsorption:
                absorptionLevels[i] = labelToAbsorption[labelName]
            else:
                absorptionLevels[i] = Absorption.MEDIUM.value
    print("numNeg: ", numNeg)
    print("numPos: ", numPos)
    return absorptionLevels
