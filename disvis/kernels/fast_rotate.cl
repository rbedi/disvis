__kernel
void rotate_image3d(sampler_t sampler, read_only image3d_t im_map, 
        float16 rotmat, __global float *out, int4 shape)
{
    /*
     * 
     */

    int zid = get_global_id(0);
    int yid = get_global_id(1);
    int xid = get_global_id(2);

    int zstride = get_global_size(0);
    int ystride = get_global_size(1);
    int xstride = get_global_size(2);

    int i, ix, iy, iz;
    int ind_z, ind_yz, ind_xyz;

    float x, y, z;
    float xcoor_z, ycoor_z, zcoor_z, xcoor_yz, ycoor_yz, zcoor_yz;
    float xcoor_xyz, ycoor_xyz, zcoor_xyz;
    float4 coor, value;

    const float hzsize = 0.5f*shape.s0;
    const float hysize = 0.5f*shape.s1;
    const float hxsize = 0.5f*shape.s2;
    const int slice = shape.s1*shape.s2;
    const float IM_OFFSET = 0.5f;


    for (iz = zid; iz < shape.s0; iz += zstride){

        // center is at (0, 0, 0)
        z = (float) iz;
        if (z >= hzsize)
            z -= shape.s0;

        xcoor_z = rotmat.s2*z;
        ycoor_z = rotmat.s5*z;
        zcoor_z = rotmat.s8*z;
        ind_z =  iz*slice;

        for (iy = yid; iy < shape.s1; iy += ystride){

            // center is at (0, 0, 0)
            y = (float) iy;
            if (y >= hysize)
                y -= shape.s1;

            xcoor_yz = rotmat.s1*y + xcoor_z; 
            ycoor_yz = rotmat.s4*y + ycoor_z; 
            zcoor_yz = rotmat.s7*y + zcoor_z; 
            ind_yz = y*shape.s2 + ind_z;

            for (ix = xid; ix < shape.s2; ix += xstride){

                // center is at (0, 0, 0)
                x = (float) ix;
                if (x >= hxsize)
                    x -= shape.s2;

                xcoor_xyz = rotmat.s0*x + xcoor_yz;
                ycoor_xyz = rotmat.s3*x + ycoor_yz;
                zcoor_xyz = rotmat.s6*x + zcoor_yz;
                ind_xyz = x + ind_yz;

                // if rotated coordinate does not fall in the interval
                // [-hsize, hsize] discard it
                if ((xcoor_xyz > hxsize) || (ycoor_xyz > hysize) || (zcoor_xyz > hzsize))
                    continue;
                if ((xcoor_xyz < -hxsize) || (ycoor_xyz < -hysize) || (zcoor_xyz < -hzsize))
                    continue;

                if (xcoor_xyz < 0.0f)
                    xcoor_xyz += shape.s2;
                if (ycoor_xyz < 0.0f)
                    ycoor_xyz += shape.s1;
                if (zcoor_xyz < 0.0f)
                    zcoor_xyz += shape.s0;

                xcoor_xyz += IM_OFFSET; 
                ycoor_xyz += IM_OFFSET; 
                zcoor_xyz += IM_OFFSET; 

                coor = (float4) (xcoor_xyz, ycoor_xyz, zcoor_xyz, 0.0f);

                value = read_imagef(im_map, sampler, coor);

                out[ind_xyz] = value.s0;
            }
        }
    }
}