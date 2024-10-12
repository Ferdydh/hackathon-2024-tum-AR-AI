import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";

const API_URL = "http://localhost:8000";

export const useGetFriends = () => {
  const getFriends = async () => {
    const response = await fetch(`${API_URL}/friends`);
    return response.json();
  };
  const {
    data: friends,
    isLoading,
    error,
  } = useQuery({
    queryKey: ["friends"],
    queryFn: getFriends,
  });

  return { friends, isLoading, error };
};

export const useGetFriend = (id?: string) => {
  const getFriend = async () => {
    const response = await fetch(`${API_URL}/friends/${id}`);
    return response.json();
  };
  const {
    data: friend,
    isLoading,
    error,
  } = useQuery({
    queryKey: ["friend", id],
    queryFn: getFriend,
    enabled: !!id,
  });

  return { friend, isLoading, error };
};

export type Friend = {
  id?: string;
  name?: string;
  image?: File;
  details?: string[];
};

export const useCreateFriend = () => {
  const createFriend = async ({ image }: Friend) => {
    const formData = new FormData();
    if (image) {
      formData.append("image", image);
    }

    const response = await fetch(`${API_URL}/friends`, {
      method: "POST",
      body: formData,
    });
    return response.json();
  };

  return useMutation({
    mutationFn: createFriend,
  });
};

export const useUpdateFriend = () => {
  const queryClient = useQueryClient();
  const updateFriend = async ({
    id,
    friend,
  }: {
    id: string;
    friend: Friend;
  }) => {
    const { name, details } = friend;
    const response = await fetch(`${API_URL}/friends/${id}`, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        name,
        details,
      }),
    })
      .then((response) => response.json())
      .then((data) => {
        if (data) {
          // Invalidate the friends query to refetch the data
          queryClient.invalidateQueries({
            queryKey: ["friend", id],
          });
          queryClient.invalidateQueries({
            queryKey: ["", id],
          });
        }
        return data;
      });

    return response;
  };
  return useMutation({
    mutationFn: updateFriend,
  });
};

export const useDeleteFriend = () => {
  const deleteFriend = async (id: string) => {
    const response = await fetch(`${API_URL}/friends/${id}`, {
      method: "DELETE",
    });
    return response.json();
  };
  return useMutation({
    mutationFn: deleteFriend,
  });
};

export const useSearchFriendByImage = () => {
  const searchFriendByImage = async (image: Blob) => {
    const formData = new FormData();
    formData.append(`image`, image);

    const response = await fetch(`${API_URL}/friends/search_by_image`, {
      method: "POST",
      body: formData,
    });
    return response.json();
  };

  return useMutation({
    mutationFn: searchFriendByImage,
  });
};
