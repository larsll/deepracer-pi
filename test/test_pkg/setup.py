from setuptools import find_packages, setup

package_name = 'test_pkg'

setup(
    name=package_name,
    version='0.0.1',
    packages=find_packages(exclude=['test']),
    data_files=[
        ('share/ament_index/resource_index/packages',
            ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),
    ],
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='Lars Lorentz Ludvigsen',
    maintainer_email='larsll@outlook.com',
    description='Equivalency testing package',
    license='MIT-0',
    tests_require=['pytest'],
    entry_points={
        'console_scripts': [
            'inference_comparison_node = test_pkg.inference_comparison_node:main'
        ],
    },
)
