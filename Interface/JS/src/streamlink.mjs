import { EventEmitter } from 'events';

import readline from 'readline';
import child_process from 'child_process';

export class Streamlink extends EventEmitter {
  #process;
  #rl;

  constructor(applicationPath) {
    super();

    this.#process = child_process.spawn(applicationPath, [], {
      detached: false,
      shell: true,
    });

    this.#rl = readline.createInterface({
      input: this.#process.stdout,
    });

    this.#observe();
  }

  close() {
    this.#process.kill('SIGINT');
  }

  #observe() { 
    this.#observeProcess();
    this.#observeRL();
  }

  #observeProcess() {
    if (this.#process.stderr) {
      this.#process.stderr.setEncoding('utf-8');
    }

    if (this.#process.stdout) {
      this.#process.stdout.setEncoding('utf-8');
    }

    this.#process.on('error', error =>
      console.log('streamlink error [pid:%d, error:%o]', this.#process.pid, error)
    );

    this.#process.once('close', () => 
      console.log('streamlink close [pid:%d]', this.#process.pid)
    );

    this.#process.stderr.on('data', data => process.stderr.write(data));
  }

  #observeRL() {
    this.#rl.on('line', (line) => {
      try {
        const request = JSON.parse(line);
        this.emit('request', request);
      } catch (error) {
        console.log('error parsing json', error);
      }
    });
  }

  send(request) {
    try {
      this.#process.stdin.write(JSON.stringify(request) + '\n');
    } catch (error) {
      console.log('error serializing json', error);
    }
  }
}
