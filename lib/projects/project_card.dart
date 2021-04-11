import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'project.dart';

class ProjectCard extends StatefulWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectCard({Key key, @required this.project, @required this.onTap})
      : super(key: key);

  @override
  _ProjectCardState createState() =>
      _ProjectCardState(this.project, this.onTap);
}

class _ProjectCardState extends State<ProjectCard> {
  final Project project;
  final VoidCallback onTap;

  _ProjectCardState(this.project, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 12),
      child: InkWell(
        splashColor: Colors.black.withOpacity(0.01),
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 158,
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment(0.0, 0.9),
                          end: Alignment(0.0, 1.0),
                          colors: [
                            const Color(0xff25f1c3),
                            const Color(0xff96EFDB),
                          ],
                          stops: [0.5, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x55000000),
                            offset: Offset(0, 3),
                            blurRadius: 4,
                          ),
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AspectRatio(
                          aspectRatio: 3 / 3.7,
                        ),
                        Text(
                          "${project.name}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "${project.role.role}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    width: 142,
                    height: 142 * 4 / 3,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(project.image),
                          fit: BoxFit.cover,
                          onError: (_, __) => Container(
                            color: Colors.white,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xbf000000),
                            offset: Offset(0, 4),
                            blurRadius: 4,
                          ),
                        ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
