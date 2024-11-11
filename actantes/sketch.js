let mic, fft;

function setup() {
  createCanvas(window.innerWidth, window.innerHeight);
  mic = new p5.AudioIn();
  mic.start();
  fft = new p5.FFT(0.8, 128);
  fft.setInput(mic);
}

function draw() {
  background(0, 10);
  let spectrum = fft.analyze();

  noStroke();
  fill(255);
  for (let i = 0; i < spectrum.length; i++) {
    let x = map(i, 0, spectrum.length, 0, width);
    let h = -height + map(spectrum[i], 0, 255, height, 0);
    rect(x, height, width / spectrum.length, h);
  }
}
