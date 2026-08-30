import numpy as np
import pyroomacoustics as pra
from scipy.io import wavfile
import os

class SimulationSettings():
    def __init__(self):
        self.order = 1
        self.ray_tracing = False
        absorption = None
        scattering = None

    def toString(self):
        s = f"order: {self.order}\n"
        s += f"raytracing: {self.ray_tracing}\n"
        if self.absorption is not None:
            s += f"absorption: {self.absorption}\n"
        else:
            s += f"absorption: -\n"
        if self.scattering is not None:
            s += f"scattering: {self.scattering}\n"
        else:
            s += f"scattering: -\n"


def simulateRoom(receivers, senders, sampleStep, roomCoords, folder, sound_file, absorption=0.2, scattering=0.25):
    corners = np.array(
    [
        [0.0, 0.0],
        [0.0, roomCoords[1]],
        [roomCoords[0], roomCoords[1]],
        [roomCoords[0], 0],
    ]
    ).T
    h = roomCoords[2]
    
    wall_material = pra.Material(energy_absorption=absorption, scattering=scattering)
    ceiling_material = pra.Material(energy_absorption=absorption, scattering=scattering)
    floor_material = pra.Material(energy_absorption=absorption, scattering=scattering)
    
    fs, signal = wavfile.read(sound_file)

    room = pra.Room.from_corners(corners, fs=fs, max_order=3, materials=wall_material, ray_tracing = False, air_absorption=True)
    room.extrude(h, materials={"floor": floor_material, "ceiling": ceiling_material})

    skipInitial = 1000000
    for i in range(len(senders[0])):
        try:
            room.add_source(senders[:, i], signal=signal[skipInitial+sampleStep*i:skipInitial+sampleStep*(i+1)], delay=i*sampleStep/fs)
        except:
            print(senders[:,i])
            print(i)
            return


    for i in range(len(receivers[0])):
        room.add_microphone(receivers[:,i])

    
    room.simulate()

    if not os.path.isdir(folder):
        os.mkdir(folder)
    if folder[-1] != '/':
        folder += "/"
        
    maxVal = np.max(np.abs(room.mic_array.signals))

    for i in range(room.mic_array.signals.shape[0]):
        filename = folder+f"sim_mic{i+1}.wav"
        wavfile.write(filename=filename, rate=fs, data=room.mic_array.signals[i,1:sampleStep*(len(senders[0])+1)]/maxVal)

    return



def simulateRoomChirp(receivers, senders, sampleStep, roomCoords, folder, sound_file, absorption=0.2, scattering=0.25):
    corners = np.array(
    [
        [0.0, 0.0],
        [0.0, roomCoords[1]],
        [roomCoords[0], roomCoords[1]],
        [roomCoords[0], 0],
    ]
    ).T
    h = roomCoords[2]
    
    wall_material = pra.Material(energy_absorption=absorption, scattering=scattering)
    ceiling_material = pra.Material(energy_absorption=absorption, scattering=scattering)
    floor_material = pra.Material(energy_absorption=absorption, scattering=scattering)
    fs, signal = wavfile.read(sound_file)


    for j in range(len(senders[0])):
        room = pra.Room.from_corners(corners, fs=fs, max_order=3, materials=wall_material, ray_tracing=False, air_absorption=True)
        room.extrude(h, materials={"floor": floor_material, "ceiling": ceiling_material})

        try:
            room.add_source(senders[:, j], signal=signal)
        except:
            print(senders[:,j])
            print(j)
            return


        for i in range(len(receivers[0])):
            room.add_microphone(receivers[:,i])

        room.simulate()

        if not os.path.isdir(folder):
            os.mkdir(folder)
        if folder[-1] != '/':
            folder += "/"
            
        maxVal = np.max(np.abs(room.mic_array.signals))

        for i in range(room.mic_array.signals.shape[0]):
            filename = folder+f"sim_mic{i+1}_source{j+1}.wav"
            wavfile.write(filename=filename, rate=fs, data=room.mic_array.signals[i,:]/maxVal)

    return


def simulateScannetppRoom(receivers, senders, sampleStep, room, folder, sound_file):
    
    fs, signal = wavfile.read(sound_file)

    skipInitial = 1000000
    for i in range(len(senders[0])):
        try:
            room.add_source(senders[:, i], signal=signal[skipInitial+sampleStep*i:skipInitial+sampleStep*(i+1)], delay=i*sampleStep/fs)
        except:
            print("A source could not be added:")
            print(senders[:,i])
            print(i)
            return


    for i in range(len(receivers[0])):
        room.add_microphone(receivers[:,i])

    room.simulate()

    if not os.path.isdir(folder):
        os.mkdir(folder)
    if folder[-1] != '/':
        folder += "/"
    
    maxVal = np.max(np.abs(room.mic_array.signals))

    for i in range(room.mic_array.signals.shape[0]):
        filename = folder+f"sim_mic{i+1}.wav"
        wavfile.write(filename=filename, rate=fs, data=room.mic_array.signals[i,1:sampleStep*(len(senders[0])+1)]/maxVal)

    return


