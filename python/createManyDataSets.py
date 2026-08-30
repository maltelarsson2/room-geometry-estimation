import createGt1
import simulateRoom

def createExperiment2(folder_base, num_rooms = 10):
    for j in range(num_rooms): #Different rooms
        print("j", j)
        receivers, senders, times, room = createGt1.createData4(6, 100)
        absorption = 0.2 #0.3
        folder = folder_base + str(j)
        createGt1.saveData(folderPath=folder, r=receivers, s=senders, t=times, room=room)
        simulateRoom.simulateRoom(receivers=receivers, senders=senders, roomCoords=room, sampleStep=5000, folder=folder, absorption=absorption, scattering=0.0)

def createExperiment_Chirp(folder_base, num_rooms = 10):
    for j in range(num_rooms): #Different rooms
        print("j", j)
        receivers, senders, times, room = createGt1.createData5(12, 17)
        absorption = 0.2
        folder = folder_base + str(j)
        createGt1.saveData(folderPath=folder, r=receivers, s=senders, t=times, room=room)
        simulateRoom.simulateRoomChirp(receivers=receivers, senders=senders, roomCoords=room, sampleStep=5000, folder=folder, absorption=absorption, scattering=0.0)


if __name__ == "__main__":
    folder_base = "path/to/result/folder"
    num_rooms = 10
    experimentNum = 1
    if experimentNum == 1:
        createExperiment2(folder_base, num_rooms)
    elif experimentNum == 2:
        createExperiment_Chirp(folder_base, num_rooms)
