include(`macros.m4')DONT_CHANGE(__file__)

# FROM ubuntu:trusty
FROM nvidia/cuda:7.5-cudnn4-devel

ENV DEBIAN_FRONTEND noninteractive
ENV INSTALL_ROOT /usr/local/src
ENV CONDA_DIR /opt/conda

COPY system-conf /

include(`build_tools.m4')
include(`create_user.m4')
