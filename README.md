# Synaesthetic

**Synaesthetic** is a multiplatform app (iOS, iPadOS, macOS) designed to transform audio input into a visual experience, blending sound and sight through particle-based abstractions.

### How It Works
The app listens to audio input from your device's microphone (you’ll need to allow microphone access), capturing the sounds and turning them into unique particle generation visuals. This is why it’s called “Synaesthetic” — translating one sense (hearing) into another (sight) for an immersive experience.

The app supports saving these visuals as live photos directly to your device's photo library, letting you capture moments of sound in visual form.

### Visualization Engine
- **Main Branch:** The main branch is powered by JavaScript and uses the [p5.js](https://p5js.org/) library for creating abstract particle visualizations.
- **Metal-Based Experiments:** Additional branches explore native Apple Metal shaders to drive visualizations. Each of these branches provides a distinct visual style but does not support saving as live photos.

### Experimental Branches
These branches use Metal shaders for visualization experiments:

- **abstract_noise**
- **sphere**
- **pointwave**

Each branch has its own unique style, showcasing different ways of visualizing audio data.

---

## Screenshots

#### Main Branch (JavaScript + p5.js)
![Main Branch Screenshot](https://github.com/fabiofranzese/actantes/blob/97a2813d4c06d07120acb6782b5354a7618d8966/screenshots/js_particles.png)

#### Metal-Based Branches (Native Metal Shaders)

- **abstract_noise**  
  ![abstract_noise Screenshot](https://github.com/fabiofranzese/actantes/blob/97a2813d4c06d07120acb6782b5354a7618d8966/screenshots/abstract_noise.PNG)

- **sphere**  
  ![sphere Screenshot](https://github.com/fabiofranzese/actantes/blob/97a2813d4c06d07120acb6782b5354a7618d8966/screenshots/sphere.PNG)

- **pointwave**  
  ![pointwave Screenshot](https://github.com/fabiofranzese/actantes/blob/97a2813d4c06d07120acb6782b5354a7618d8966/screenshots/pointwave.PNG)

