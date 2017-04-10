from setuptools import setup

setup(
    name='database',
    version='0.1',
    py_modules=['database', 'image_files'],
    install_requires=['sqlalchemy', 'pandas'])
