FROM ubuntu AS builder
RUN apt-get update
RUN apt-get install git cmake build-essential -y
RUN mkdir /deps /proj
WORKDIR /deps
RUN git clone https://github.com/oatpp/oatpp --depth 1 --branch master
RUN mkdir oatpp/build
WORKDIR /deps/oatpp/build
RUN cmake -DCMAKE_BUILD_TYPE=Release -DOATPP_BUILD_TESTS=OFF -DOATPP_DISABLE_ENV_OBJECT_COUNTERS=ON ..
RUN make install
WORKDIR /deps
RUN rm -r oatpp
RUN git clone https://github.com/Error10556/d-interpreter --depth 1 --branch main dinterp
RUN mkdir /deps/dinterp/build
WORKDIR /deps/dinterp/build
RUN cmake -DCMAKE_BUILD_TYPE=Release -DTesting=OFF -DInstallInterpreter=OFF -DInstallSDK=ON ../src
RUN make install
WORKDIR /proj
RUN rm -r /deps/dinterp
COPY ./CMakeLists.txt ./CMakeLists.txt
COPY ./dinteroper.cpp ./dinteroper.cpp
COPY ./dinteroper.h ./dinteroper.h
COPY ./main.cpp ./main.cpp
COPY ./statusMap.cpp ./statusMap.cpp
COPY ./statusMap.h ./statusMap.h
RUN mkdir build && cd build && cmake -DCMAKE_BUILD_TYPE=Release .. && make

FROM ubuntu
RUN mkdir /app
WORKDIR /app
COPY --from=builder /proj/build/dsite /usr/bin/dsite
ENTRYPOINT ["/usr/bin/dsite"]
