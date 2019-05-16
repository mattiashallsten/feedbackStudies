# Feedback studies

Generative bits of SuperCollider code utilizing feedback. Most of them can run for an indefinate duration.

## Instability

This project is an attempt of showing how the experience of instability in sound can affect our perception of what is real and what is not. Real-world sounds tend to be experienced as unstable due to the complex systems they are part of -- sound sources are altered due to complex connections *within* the sound source as well as *outside* the sound source, and sounds themselves are altered due to changes in the air, other objects and the listeners perspective.

Feedback can be an effective way of mimicking these complex systems, and create sounds which sound and behave as though they are real when in fact they aren't -- they exist only inside of a computer passing one's and zero's around. This REALLY intrigues me.

## Regarding the snippets

All the SuperCollider code is made so that the user only has to evaluate the code block once -- everything is contained with a `s.waitForBoot`-function, so the server boots, `SynthDef`s are loaded and the `Pbind`s play. Evaluation is done in the SuperCollider IDE using CMD+Return after placing the cursor inside the code block (anywhere in the file), or in my case in the `scel` package with C-M-x.
