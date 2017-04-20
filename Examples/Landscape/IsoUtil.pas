unit IsoUtil;
interface
procedure Iso2Line(Xmap,Ymap:Integer;out Xline,Yline:Integer);
procedure Line2Iso(Xline,Yline:Integer;out Xmap,Ymap:Integer);
procedure TileAtCoord(Xcoord,Ycoord,TileWidth,TileHeight:Integer;out Xmap,Ymap:Integer);
procedure CoordAtTile(Xmap,Ymap,TileWidth,TileHeight:Integer;out Xcoord,Ycoord:Integer);
implementation

procedure Iso2Line(Xmap,Ymap:Integer;out Xline,Yline:Integer);
begin
 Yline:=(Ymap shr 1)-Xmap;
 Xline:=Xmap+(Ymap and 1)+(Ymap shr 1);
end;

procedure Line2Iso(Xline,Yline:Integer;out Xmap,Ymap:Integer);
begin
 Xmap:=(Xline-Yline) shr 1;
 Ymap:=Xline+Yline;
end;

procedure TileAtCoord(Xcoord,Ycoord,TileWidth,TileHeight:Integer;out Xmap,Ymap:Integer);
Var Thh,Twh:Integer;
begin
 Twh:=TileWidth div 2;
 Thh:=TileHeight div 2;
 Ymap:=Ycoord div Thh;
 Xmap:=(Xcoord-((Ymap and 1)*Twh)) div TileWidth;
end;

procedure CoordAtTile(Xmap,Ymap,TileWidth,TileHeight:Integer;out Xcoord,Ycoord:Integer);
Var Thh,Twh:Integer;
begin
 Twh:=TileWidth div 2;
 Thh:=TileHeight div 2;
 Ycoord:=Ymap*Thh;
 Xcoord:=(Xmap*TileWidth)+((Ymap and 1)*Twh);
end;

end.
 