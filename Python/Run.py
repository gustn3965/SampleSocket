import socket
import threading
from queue import Queue
count = 0

def Send(group, sendQueue):
    print('New Thread')
    while True:
        if len(group) == 0:
            return
        print('\n')
        recv = sendQueue.get()
        keep = []
        if recv == 'Group Changed':
            print('Group Changed')
            break
        for connection in group:
            message = recv[0]
            print('send - ', message)
            connection.send(bytes(message.encode('utf-8', 'ignore')))
            try:
                if str(recv[0]).find('end') != -1 and recv[1] == connection:
                    if connection in group:
                        keep.append(connection)
                        global count
                        count = count - 1
            except:
                pass

        for connection in keep:
            group.remove(connection)
            print('removed')

def Recv(conn, count, sendQueue):
    
    while True:
        data = conn.recv(1024).decode('utf-8')
        print('Thread Recv' + data )
        try:
            if 'end' in str(data):
                sendQueue.put([data, conn, count])
                return
            else:
                sendQueue.put([data, conn, count])
        except:
            sendQueue.put([data, conn, count])


sendQueue = Queue()
group = []
host = "172.30.1.33"
port = 8080
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((host, port))
s.listen(5)
a = 5


while True:
    count = count + 1
    connectionSock, addr = s.accept()
    print('new chet!')
    group.append(connectionSock)

    if count > 1:
        sendQueue.put('Group Changed')
        thread1 = threading.Thread(target=Send, args=(group, sendQueue,))
        thread1.start()
        pass
    else:
        thread1 = threading.Thread(target=Send, args=(group, sendQueue,))
        thread1.start()

    thread2 = threading.Thread(target=Recv, args=(connectionSock, count, sendQueue,))
    thread2.start()

s.close()


