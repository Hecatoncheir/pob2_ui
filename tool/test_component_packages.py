"""Unix-права runtime сохраняются при сборке архива на Windows."""

import io
from pathlib import Path
import tarfile
import tempfile
import unittest
from unittest.mock import patch
import zipfile

import package_components as packages


class ComponentPackagesTests(unittest.TestCase):
    def test_original_tar_modes_override_host_filesystem_modes(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / 'source'
            executable = source / 'python/bin/python3'
            executable.parent.mkdir(parents=True)
            executable.write_bytes(b'python')
            executable.chmod(0o644)
            target = 'linux-x64'
            architecture = packages.PYTHON_ASSETS[target][0]
            name = f'{packages.PYTHON_PREFIX}{architecture}-install_only_stripped.tar.gz'
            with tarfile.open(root / name, 'w:gz') as archive:
                entry = tarfile.TarInfo('python/bin/python3')
                entry.mode, entry.size = 0o755, 6
                archive.addfile(entry, io.BytesIO(b'python'))
            output = root / 'mcp.zip'
            with patch.object(packages, 'unpack_mcp', return_value=source):
                packages.pack_mcp(output, root, target, source)
            with zipfile.ZipFile(output) as archive:
                self.assertEqual(archive.getinfo('python/bin/python3').create_system, 3)
                mode = archive.getinfo('python/bin/python3').external_attr >> 16
                self.assertEqual(mode & 0o777, 0o755)
                self.assertEqual(archive.read('python/bin/python3'), b'python')


if __name__ == '__main__':
    unittest.main()
