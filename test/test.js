const { expect } = require("chai");
const { ethers } = require("hardhat");
const { writeFileSync } = require('fs');

describe("Blobs", function () {
  it("Should render svg from randomly generated params", async function () {
    const [owner, user1] = await ethers.getSigners();
    const Blobs = await ethers.getContractFactory("Blobs");
    const blobs = await Blobs.deploy();
    await blobs.deployed();

    params = await blobs.generate_svg_params();
    console.log(Object.keys(params).filter(each => each.length == 1).sort().map(each => ([each, params[each].toString()])));
    const renderParam = Object.keys(params).filter(each => each.length == 1).sort().map(each => (params[each].toString()));
    const svg = await blobs.render_svg(renderParam);
    console.log(svg);
  });
});
