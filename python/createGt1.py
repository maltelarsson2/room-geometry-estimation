import numpy as np
import math
from scipy.io import wavfile
import pyroomacoustics as pra
import collections.abc
from pathlib import Path



def createData4(numR, numS):
    rng = np.random.default_rng()
    min_width = 1
    max_width = 10
    room = min_width+(max_width-min_width)*rng.random(3) #[x, y, z] > 0 - opposite corners in (0,0,0) and [x, y, z], planes parallel with axes-planes
    r = rng.random((3, numR))
    Ps = rng.random((3, 4))
    for i in range(3):
        r[i,:] *= room[i]
        Ps[i,:] *= room[i]
    t_vals = [1*n/(numS-1) for n in range(numS)]
    s = cubicBezierCurve(Ps[:, 0], Ps[:, 1], Ps[:, 2], Ps[:, 3], t_vals)
    return r, s, [], room

def createData5(numR, numS):
    rng = np.random.default_rng()
    min_width = 1
    max_width = 10
    room = min_width+(max_width-min_width)*rng.random(3) #[x, y, z] > 0 - opposite corners in (0,0,0) and [x, y, z], planes parallel with axes-planes


    r = rng.random((3, numR))
    for i in range(3):
        r[i,:] *= room[i]
    sources = rng.random((3, numS))
    for i in range(3):
        sources[i,:] *= room[i]
    t = []
    return r, sources, t, room

def createDataScannetpp(numR, numS, R, t, s):
    rng = np.random.default_rng()
    room = [1, 1, 1] #[x, y, z] > 0 - opposite corners in (0,0,0) and [x, y, z], planes parallel with axes-planes

    r = rng.random((3, numR))
    Ps = rng.random((3, 4))
    for i in range(3):
        r[i,:] *= room[i]
        Ps[i,:] *= room[i]
    t_vals = [1*n/(numS-1) for n in range(numS)]
    sources = cubicBezierCurve(Ps[:, 0], Ps[:, 1], Ps[:, 2], Ps[:, 3], t_vals)

    r = transform111ToScannetRts(r, R, t, s)
    sources = transform111ToScannetRts(sources, R, t, s)
    return r, sources

def createCompareDataScannetpp(numR, numS, R, t, s):
    room = [1, 1, 1] #[x, y, z] > 0 - opposite corners in (0,0,0) and [x, y, z], planes parallel with axes-planes
    r = np.asarray([[0.4067, 0.7359, 0.8302, 0.7201, 0.3887, 0.5658], [0.3111, 0.1924, 0.0782, 0.1397, 0.6838, 0.9611], [0.9361, 0.1798, 0.7023, 0.2566, 0.9843, 0.3257]])
    p1 = [0.3, 0.3, 0.5]
    p2 = [0.3, 0.3, 0.7]
    sources = createLineSegment(p1, p2, numS)
    for i in range(3):
        r[i,:] *= room[i]
        sources[i,:] *= room[i]

    r = transform111ToScannetRts(r, R, t, s)
    sources = transform111ToScannetRts(sources, R, t, s)
    return r, sources



def transform111ToScannetRts(points, R, t, s):
    points *= np.expand_dims(s, 1)
    points -= np.expand_dims(s, 1)/2
    points = R.transpose()@(points-np.expand_dims(t, 1))
    return points


def createData_deterministic(numR, numS):
    rng = np.random.default_rng(37)
    room = [5, 7, 2.5] #[x, y, z] > 0 - opposite corners in (0,0,0) and [x, y, z], planes parallel with axes-planes

    r = rng.random((3, numR))
    for i in range(3):
        r[i,:] *= room[i]
    sources = rng.random((3, numS))
    for i in range(3):
        sources[i,:] *= room[i]
    t = []
    return r, sources, t, room


def simulateRoom(receivers, sources, times, room):
    fs, signal = wavfile.read("Track 1.wav")
    corners = np.array(
        [
            [0.0, 0.0],
            [0.0, room[1]],
            [room[2], room[1]],
            [room[2], 0],
        ]
    ).T
    h = room[3]

    wall_material = pra.Material(energy_absorption=0.5, scattering=0.25)
    ceiling_material = pra.Material(energy_absorption=0.5, scattering=0.25)
    floor_material = pra.Material(energy_absorption=0.5, scattering=0.25)
    room = pra.Room.from_corners(corners, fs=fs, max_order=5, materials=wall_material, ray_tracing=True, air_absorption=True)
    
    # room.extrude(h, materials=ceiling_material)
    room.extrude(h, materials={"floor": floor_material, "ceiling": ceiling_material})
    room.set_ray_tracing(receiver_radius=0.1, n_rays=10000, energy_thres=1e-7)

    skipInitial = 1000000
    for i in range(len(sources)):
        room.add_source(sources[i], signal=signal[skipInitial+5000*i:skipInitial+5000*(i+1)], delay=i*5000/fs)

    for i in range(len(receivers)):
        room.add_microphone(receivers[i])




    pass

def saveNote(folderPath, note):
    if folderPath[-1] != '/':
        folderPath += "/"
    f = open(folderPath + "note.txt", "w")
    f.write(note)
    f.close()


def saveData(folderPath, r, s, t, room):
    Path(folderPath).mkdir(parents=False, exist_ok=True)
    saveMatrix(folderPath=folderPath, fileName="receivers.txt", matrix=r)
    saveMatrix(folderPath=folderPath, fileName="senders.txt", matrix=s)
    saveMatrix(folderPath=folderPath, fileName="times.txt", matrix=t)
    saveMatrix(folderPath=folderPath, fileName="room.txt", matrix=room)
    return
    
def saveMatrix(folderPath, fileName, matrix):
    if folderPath[-1] != '/':
        folderPath += "/"
    f = open(folderPath + fileName, "w")
    for i in range(len(matrix)):
        if isinstance(matrix[0], (collections.abc.Sequence, np.ndarray)):
            for j in range(len(matrix[0])):
                f.write(f"{matrix[i][j]} ")
        else:
            f.write(f"{matrix[i]} ")
        f.write("\n")
    f.close()

def readMatrix(folderPath, fileName):
    matrix = []
    if folderPath[-1] != '/':
        folderPath += "/"
    with open(folderPath + fileName, "r") as f:
        for line in f:
            row = []
            for number in line.split():
                if number:
                    row.append(float(number))
            matrix.append(row)
    return np.asarray(matrix)

def quadBezierCurve(P0, P1, P2, tvals):
    pos = np.zeros((3, len(tvals)))
    for t_ind in range(len(tvals)):
        t = tvals[t_ind]
        pos[:, t_ind] = (1-t)*((1-t)*P0+t*P1)+t*((1-t)*P1+t*P2)
    return pos

def cubicBezierCurve(P0, P1, P2, P3, tvals):
    pos1 = quadBezierCurve(P0, P1, P2, tvals)
    pos2 = quadBezierCurve(P1, P2, P3, tvals)
    
    pos = np.zeros((3, len(tvals)))
    for t_ind in range(len(tvals)):
        t = tvals[t_ind]
        pos[:, t_ind] = (1-t)*pos1[:, t_ind]+t*pos2[:, t_ind]
    return pos

def createLineSegment(p1, p2, n):
    pos = np.zeros((3, n))
    for i in range(3):
        pos[i,:] = [(1-t/(n-1))*p1[i]+t/(n-1)*p2[i] for t in range(n)]
    return pos


