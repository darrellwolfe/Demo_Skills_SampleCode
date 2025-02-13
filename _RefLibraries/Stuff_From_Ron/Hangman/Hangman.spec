# -*- mode: python ; coding: utf-8 -*-
from PyInstaller.utils.hooks import collect_submodules

hiddenimports = ['pandas', 'pandas._libs.tslibs.base', 'pandas._libs.tslibs.np_datetime', 'pandas._libs.tslibs.timedeltas', 'pandas._libs.tslibs.timedeltas', 'pandas._libs.tslibs.timedeltas']
hiddenimports += collect_submodules('openpyxl')


a = Analysis(
    ['Hangman.py'],
    pathex=[],
    binaries=[],
    datas=[('acronyms.xlsx', '.')],
    hiddenimports=hiddenimports,
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name='Hangman',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
