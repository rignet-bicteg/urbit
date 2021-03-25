import React from "react";
import { Anchor, Icon, Box, Row, Col, Text } from "@tlon/indigo-react";
import ChatMessage from "../chat/components/ChatMessage";
import { Association, GraphNode } from "@urbit/api";
import { useGroupForAssoc } from "~/logic/state/group";
import { MentionText } from "~/views/components/MentionText";
import Author from "~/views/components/Author";
import { NoteContent } from "../publish/components/Note";
import bigInt from "big-integer";
import { getSnippet } from "~/logic/lib/publish";
import { NotePreviewContent } from "../publish/components/NotePreview";
import GlobalApi from "~/logic/api/global";

function TranscludedLinkNode(props: {
  node: GraphNode;
  assoc: Association;
  transcluded: number;
  api: GlobalApi;
}) {
  const { node, api, assoc, transcluded } = props;
  const idx = node.post.index.slice(1).split("/");

  switch (idx.length) {
    case 1:
      const [{ text }, { url }] = node.post.contents;
      return (
        <Box borderRadius="2" p="2" bg="scales.black05">
          <Anchor underline={false} target="_blank" color="black" href={url}>
            <Icon verticalAlign="bottom" mr="2" icon="ArrowExternal" />
            {text}
          </Anchor>
        </Box>
      );
    case 2:
      return (
        <TranscludedComment
          api={api}
          transcluded={transcluded}
          node={node}
          assoc={assoc}
        />
      );
    default:
      return null;
  }
}

function TranscludedComment(props: {
  node: GraphNode;
  assoc: Association;
  api: GlobalApi;
  transcluded: number;
}) {
  const { assoc, node, api, transcluded } = props;
  const group = useGroupForAssoc(assoc)!;

  const comment = node.children?.peekLargest()![1]!;
  return (
    <Col>
      <Author
        p="2"
        showImage
        ship={comment.post.author}
        date={comment.post?.["time-sent"]}
        group={group}
      />
      <Box p="2">
        <MentionText
          api={api}
          transcluded={transcluded}
          content={comment.post.contents}
          group={group}
        />
      </Box>
    </Col>
  );
}

function TranscludedPublishNode(props: {
  node: GraphNode;
  assoc: Association;
  api: GlobalApi;
  transcluded: number;
}) {
  const { node, assoc, transcluded, api } = props;
  const group = useGroupForAssoc(assoc)!;
  const idx = node.post.index.slice(1).split("/");
  switch (idx.length) {
    case 1:
      const post = node.children
        ?.get(bigInt.one)
        ?.children?.peekLargest()?.[1]!;
      return (
        <Col gapY="2">
          <Author
            px="2"
            showImage
            ship={post.post.author}
            date={post.post?.["time-sent"]}
            group={group}
          />
          <Text px="2" fontSize="2" fontWeight="medium">
            {post.post.contents[0]?.text}
          </Text>
          <Box p="2">
            <NotePreviewContent
              snippet={getSnippet(post?.post.contents[1]?.text)}
            />
          </Box>
        </Col>
      );

    case 3:
      return (
        <TranscludedComment
          transcluded={transcluded}
          api={api}
          node={node}
          assoc={assoc}
        />
      );
    default:
      return null;
  }
}

export function TranscludedNode(props: {
  assoc: Association;
  node: GraphNode;
  transcluded: number;
  api: GlobalApi;
}) {
  const { node, assoc, transcluded } = props;
  const group = useGroupForAssoc(assoc)!;
  switch (assoc.metadata.config.graph) {
    case "chat":
      return (
        <Row width="100%" flexShrink={0} flexGrow={1} flexWrap="wrap">
          <ChatMessage
            width="100%"
            renderSigil
            transcluded={transcluded + 1}
            containerClass="items-top cf hide-child"
            association={assoc}
            group={group}
            groups={{}}
            msg={node.post}
            fontSize="0"
            ml="0"
            mr="0"
            pt="2"
          />
        </Row>
      );
    case "publish":
      return <TranscludedPublishNode {...props} />;
    case "link":
      return <TranscludedLinkNode {...props} />;
    default:
      return null;
  }
}
