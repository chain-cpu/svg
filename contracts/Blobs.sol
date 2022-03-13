//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.11;

import "hardhat/console.sol";
import "./Math.sol";
import "base64-sol/base64.sol";

contract Blobs {

    using Math for Blobs;
    using Base64 for Blobs;

    // string constant prefix = "<svg viewBox=\"0 0 500 500\" preserveAspectRatio=\"none\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" width=\"100%\" id=\"blobSvg\"><rect width=\"100%\" height=\"100%\" fill=\"green\" /><g><defs><linearGradient id=\"gradient\" x1=\"0%\" y1=\"0%\" x2=\"0%\" y2=\"100%\"><stop offset=\"0%\" style=\"stop-color: rgb(76, 161, 175);\"></stop><stop offset=\"100%\" style=\"stop-color: rgb(196, 224, 229);\"></stop></linearGradient></defs><path fill=\"url(#gradient)\"><animate attributeName=\"d\" dur=\"10000ms\" repeatCount=\"indefinite\" values=\"";
    string constant prefix1 = "<svg viewBox=\"0 0 500 500\" preserveAspectRatio=\"none\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" width=\"100%\" id=\"blobSvg\"><defs><filter id=\"f1\" x=\"0\" y=\"0\"><feGaussianBlur in=\"SourceGraphic\" stdDeviation=\"";
    string constant prefix2 = "\"/></filter></defs><rect width=\"100%\" height=\"100%\" fill=\"";
    string constant prefix3 = "\" /><g><defs><linearGradient id=\"gradient\" x1=\"0%\" y1=\"0%\" x2=\"0%\" y2=\"100%\"><stop offset=\"0%\" style=\"stop-color:";
    string constant prefix4 = ";\"></stop><stop offset=\"100%\" style=\"stop-color:";
    string constant prefix5 = ";\"></stop></linearGradient></defs><path filter=\"url(#f1)\" fill=\"url(#gradient)\"><animate attributeName=\"d\" dur=\"";
    string constant prefix6 = "ms\" repeatCount=\"indefinite\" values=\"";
    
    string constant suffix = "\"></animate></path></g></svg>";

    struct SVGParams {
        uint seed;
        uint randomness;
        uint complexity;
        uint animation_speed;
        uint number_of_movement;
        uint blur_value;
        string gradient_color1;
        string gradient_color2;
        string background_color;
    }

    string[] background_colors = ["#cb997e","#ddbea9","#ffe8d6","#b7b7a4","#a5a58d","#6b705c"];
    string[] colors = ["#001219","#0a9396","#94d2bd","#ee9b00","#bb3e03","#ffb703", "#9b2226"];

    function _createPoints(uint size, uint randomness, uint complexity, uint seed) view public returns(string memory path){
        uint outerRad = size / 2;
        uint innerRad = randomness * (outerRad / 10);
        uint center = size / 2; 

        uint16[] memory slices = _divide(complexity);

        uint mask = 0xffffffff;
        uint m_w = (123456789 + seed) & mask;
        uint m_z = (987654321 - seed) & mask;

        uint rand;
        uint O;
        uint x;
        uint y;

        uint[] memory destPoints = new uint[](slices.length * 2);

        for(uint i; i < slices.length; i+= 1) {
            m_z = (36969 * (m_z & 65535) + (m_z >> 16)) & mask;
            m_w = (18000 * (m_w & 65535) + (m_w >> 16)) & mask;

            rand = ((m_z << 16) + (m_w & 65535)) >> 0 & mask;
            // rand /= 4294967296;

            O = _magicPoint(rand, innerRad, outerRad);
            (x, y) = _point(center, O, slices[i]);
            destPoints[i * 2] = x;
            destPoints[i * 2 + 1] = y;
            console.log("%d %d", x, y);
        }
        path = _createSvgPath(destPoints);
        console.log(path);
    }

    function _createSvgPath(uint[] memory points) pure public returns(string memory svgPath) {
        uint mid0 = (points[0] + points[2]) / 2;
        uint mid1 = (points[1] + points[3]) / 2;
        svgPath = string(abi.encodePacked("M", Math.uint2str(mid0), ",", Math.uint2str(mid1)));
        uint i1;
        uint i2;
        for (uint i; i < points.length/2; i++) {
            i1 = (i + 1) * 2 % points.length;
            i2 = (i + 2) * 2 % points.length;
            mid0 = (points[i1] + points[i2]) / 2;
            mid1 = (points[i1 + 1] + points[i2 + 1]) / 2;
            svgPath = string(abi.encodePacked(svgPath, "Q", Math.uint2str(points[i1]),",", 
            Math.uint2str(points[i1+1]), ",", Math.uint2str(mid0),
            ",", Math.uint2str(mid1)));
        }
        svgPath = string(abi.encodePacked(svgPath, "Z"));
        return svgPath;
    }

    function _divide(uint count) pure public returns(uint16[] memory slices) {
        uint deg = 1e8 * 16384 / count;
        slices = new uint16[](count);
        for(uint i = 0; i < count; i += 1) {
            slices[i] = uint16(i * deg / 1e8);
        }
    }

    function _magicPoint(uint value, uint min, uint max) pure public returns(uint radius) {
        radius = min + value * (max - min) / 4294967296;
        if (radius > max) {
            radius = radius - min;
        } else if (radius < min) {
            radius = radius + min;
        }
    }

    function _point(uint origin, uint radius, uint16 degree) pure public returns(uint x, uint y) {
        x = uint(int(origin) + int(radius) * Math.cos(degree) / 32767);
        y = uint(int(origin) + int(radius) * Math.sin(degree) / 32767);
    }

    function generate_seed() internal view returns(uint seed) {
        seed = (uint160(msg.sender) + block.timestamp) % 987654321;
    }

    function generate_svg_params() public view returns(SVGParams memory) {
        uint seed = generate_seed();
        SVGParams memory svgParams;
        svgParams.gradient_color1 = colors[seed % colors.length];
        svgParams.gradient_color2 = colors[seed * 2 % colors.length];
        svgParams.background_color = background_colors[seed * 3 % background_colors.length];
        svgParams.complexity = 8 + (seed % 5);
        svgParams.randomness = seed % 8;
        svgParams.animation_speed = 500 + seed % 10 * 100;
        svgParams.number_of_movement = 5 + (seed % 5);
        svgParams.blur_value = seed % 5;
        svgParams.seed = seed;
        return svgParams;
        // return render_svg(svgParams);
    }

    function render_svg(SVGParams memory svgParams) public view returns(string memory) {
        string memory path = string(abi.encodePacked(
            prefix1, Math.uint2str(svgParams.blur_value),
            prefix2, svgParams.background_color,
            prefix3, svgParams.gradient_color1,
            prefix4, svgParams.gradient_color2,
            prefix5, Math.uint2str(svgParams.animation_speed * svgParams.number_of_movement),
            prefix6
        ));
        for(uint i; i <= svgParams.number_of_movement; i += 1) {
            path = string(abi.encodePacked(path, 
                _createPoints(500, svgParams.randomness, svgParams.complexity, svgParams.seed * (i % svgParams.number_of_movement) % 987654321), ";"));
        }
        path = strConcat(path, suffix);
        return strConcat("data:image/svg+xml;base64,", Base64.encode(bytes(path)));   
        // return path;
    }

    function strConcat(string memory _a, string memory _b) internal pure returns(string memory) {
        return string(abi.encodePacked(_a, _b));
    }
    
}
