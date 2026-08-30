import createScannetRoom
import createGt1
from scipy.io import wavfile
import matplotlib.pyplot as plt
import time
import simulateRoom

def createScannetppSimulation(room_id, out_folder, room_filename, semantic_room_filename, sound_file):
    # fs, _ = wavfile.read("Track 1.wav")
    fs, _ = wavfile.read(sound_file)
    t1 = time.time()
    different_materials = True
    if different_materials:
        room, R, t, s = createScannetRoom.createRoom_materials(room_filename, semantic_room_filename, room_id, fs)
    else:
        room, R, t, s = createScannetRoom.createRoom2(room_filename, room_id, fs)
    print(time.time()-t1)

    # room.plot()
    # plt.show()


    receivers, senders = createGt1.createDataScannetpp(6, 100, R, t, s)
    receivers, senders = createGt1.createCompareDataScannetpp(6, 10, R, t, s)

    note = "Note related to run"
    createGt1.saveNote(folderPath=out_folder, note=note)
    createGt1.saveData(folderPath=out_folder, r=receivers, s=senders, t=[], room=s)
    t1 = time.time()
    simulateRoom.simulateScannetppRoom(receivers=receivers, senders=senders, sampleStep=5000, room=room, folder=out_folder)
    print(time.time()-t1)


if __name__ == "__main__":
    #very slow/unrunnable if mesh is too large
    room_filename = "PATH/TO/MESH/reduced_mesh_20000.ply"
    semantic_room_filename = "PATH/TO/scannetpp/data/data/ROOM_ID/scans/mesh_aligned_0.05_semantic.ply"
    room_id = "4e9ab3ec88"
    out_folder = "FOLDER/TO/SAVE/RESULTS/IN/"
    sound_file = "PATH/TO/SOUND/FILE/Overture to The Marriage of Figaro, K. 492.wav"

    createScannetppSimulation(room_id, out_folder=out_folder, room_filename=room_filename, sound_file=sound_file)

