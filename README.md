After knitting and rendering `getReadySimulationFiles.Rmd`, overwrite this file with a symlink to `getReadySimulationFiles.md`.

E.g., on Linux/macOS from terminal:

```bash
cd /home/tmichele/projects/getReadySimulationFiles
rm README.md && ln -s getReadySimulationFiles.md README.md
```
