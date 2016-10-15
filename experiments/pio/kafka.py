from kiel import clients
from tornado import gen, ioloop

@gen.coroutine
def consume():
    print("consuming...")
    c = clients.SingleConsumer(brokers=["localhost"])

    yield c.connect()

    while True:
        msgs = yield c.consume("examples.colors")
        for msg in msgs:
            print(msg["color"])


def run():
    loop = ioloop.IOloop.instance()

    loop.add_callback(consume)

    try:
        loop.start()
    except KeyboardInterrupt:
        loop.stop()

if __name__ == '__main__':
	run()
