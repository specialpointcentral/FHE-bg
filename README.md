# Background of Fully Homomorphic Encryption

This repository contains LaTeX source files for a presentation on the background of Fully Homomorphic Encryption (FHE), covering CKKS and TFHE schemes.

## Content

**Title:** Background of Fully Homomorphic Encryption  
**Subtitle:** CKKS and TFHE  
**Author:** HU Qi  
**Institution:** The University of Hong Kong

The presentation covers:
- Motivation and definition of FHE
- Core cryptographic concepts
- CKKS and TFHE encryption schemes
- Applications in privacy-preserving computing

## Building the PDF

### Prerequisites

You need a LaTeX distribution installed. On Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install -y texlive-latex-base texlive-latex-extra \
                        texlive-fonts-recommended texlive-fonts-extra
```

### Compilation

To compile the LaTeX document:

```bash
make
```

Or manually:

```bash
pdflatex -interaction=nonstopmode main.tex
pdflatex -interaction=nonstopmode main.tex
```

The compiled PDF will be `main.pdf`.

### Clean Build Artifacts

```bash
make clean
```

## Automatic Building

This repository uses GitHub Actions to automatically compile the LaTeX document:

- **On every push to main**: The PDF is compiled and uploaded as an artifact
- **On tag push** (e.g., `v1.0.0`): A GitHub release is created with the PDF attached

### Creating a Release

To create a new release:

```bash
git tag v1.0.0
git push origin v1.0.0
```

The GitHub Actions workflow will automatically:
1. Compile the LaTeX document
2. Create a GitHub release
3. Attach the PDF to the release

## Downloads

- **Latest compiled PDF**: Check the [Releases](../../releases) page
- **Workflow artifacts**: Available in the [Actions](../../actions) tab after each build

## License

Please refer to the original author for licensing information.
