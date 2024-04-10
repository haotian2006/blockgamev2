type Shared = {
    Fps : number,
    Memory : number,
    Send : number,
    Recv : number,
    HeartbeatTime : number,
}

export type Stats_Client = {
    Location : Vector3,
    Chunk : Vector3,
    Biome : string,
    BiomeId : number,
    Velocity : Vector3,
    Region : Vector2,

    Render_SubChunk : number,
    Render_Cull : number,
    Render_Build : number,

    Render_Cache_Block : number,
    Render_Cache_Texture : number,

}&Shared

export type Stats_Server = {
    Gen_Chunks : number,
    Gen_Weak_Chunks : number,
    Gen_Destroy_Stack : number,

}&Shared

export type Stats = {
    Client : Stats_Client?,
    Server : Stats_Server
}

return {}