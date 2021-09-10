# bashrc.d

My bash Run Commands Directory

## Install

```
git clone git@github.com:wandersonwhcr/bashrc.d ~/.bashrc.d

cat <<'EOF' >> ~/.bashrc
for filename in `find ~/.bashrc.d/ -type f -name '*.bashrc'`; do
    source $filename
done
EOF
```
